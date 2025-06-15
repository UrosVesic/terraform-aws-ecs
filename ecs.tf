data "aws_ecr_repository" "repo" {
  name = "social-network"
}

module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws//modules/cluster"
  cluster_name = "social-network-cluster"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

}

resource "aws_security_group" "alb-sg" {

  name   = "alb-sg"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "task_sg" {

  name   = "container-to-alb-sg"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }
}

resource "aws_lb" "main" {
  name               = "social-network-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "main-tg" {
  name        = "social-network-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main-tg.arn
  }
}

resource "aws_ecs_task_definition" "main" {
  family             = "social-network"
  requires_compatibilities = ["FARGATE"]
  network_mode       = "awsvpc"
  cpu                = "1024"
  memory             = "2048"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name   = "social-network-container"
      image  = "${data.aws_ecr_repository.repo.repository_url}:latest"
      cpu    = 1024
      memory = 2048
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      essential = true
      environment = [
        {
          name  = "ENV"
          value = "environment!!"
        },
        {
          name  = "DB_HOSTNAME"
          value = aws_db_instance.mysql.address
        },
        {
          name = "AWS_ACCOUNT_ID",
          value = var.account_id
        }
      ]
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.mysql.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.mysql.arn}:password::"
        },
        {
          name      = "OPENAI_API_KEY"
          valueFrom = "arn:aws:secretsmanager:eu-central-1:288761758415:secret:social-network-secrets-XixHyr:OPENAIAPI_KEY::"
        },
        {
          name      = "JWT_ISSUER_URI"
          valueFrom = "arn:aws:secretsmanager:eu-central-1:288761758415:secret:social-network-secrets-XixHyr:JWT_ISSUER_URI::"
        },
        {
          name      = "AWS_CLIENT_ID"
          valueFrom = "arn:aws:secretsmanager:eu-central-1:288761758415:secret:social-network-secrets-XixHyr:AWS_CLIENT_ID::"
        },
        {
          name      = "AWS_CLIENT_SECRET"
          valueFrom = "arn:aws:secretsmanager:eu-central-1:288761758415:secret:social-network-secrets-XixHyr:AWS_CLIENT_SECRET::"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_app.name
          awslogs-region        = "eu-central-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_app" {
  name = "/ecs/social-network"
}


module "ecs_service" {
  source      = "terraform-aws-modules/ecs/aws//modules/service"
  cluster_arn = module.ecs_cluster.arn
  cpu         = 2048
  memory      = 4096

  task_definition_arn    = aws_ecs_task_definition.main.arn
  family                 = "service"
  name                   = "social-network-service"
  subnet_ids             = module.vpc.private_subnets
  create_task_definition = false
  security_group_ids = [aws_security_group.task_sg.id]
  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.main-tg.arn
      container_name   = "social-network-container"
      container_port   = 8080
    }
  }

}