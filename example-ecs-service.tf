module "ecs_service" {
  source      = "terraform-aws-modules/ecs/aws//modules/service"
  cluster_arn = module.ecs_cluster.arn
  cpu         = 2048
  memory      = 4096

  task_definition_arn    = aws_ecs_task_definition.example-task-def.arn
  family                 = "service"
  name                   = "example-service"
  subnet_ids             = module.vpc.private_subnets
  create_task_definition = false
  security_group_ids     = [aws_security_group.container-from-alb-sg.id]

}


resource "aws_ecs_task_definition" "example-task-def" {
  family = "service"

  container_definitions = jsonencode([
    {
      name   = "example-container"
      image  = "${var.account_id}.dkr.ecr.eu-central-1.amazonaws.com/test-repo:latest"
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
        }
      ]
      #   secrets = [
      #     {
      #       name      = "DB_USERNAME"
      #       valueFrom = "arn:aws:secretsmanager:eu-central-1:${var.account_id}:secret:variables-QT5rhd:DB_USERNAME::"
      #     },
      #     {
      #       name      = "DB_PASSWORD"
      #       valueFrom = "arn:aws:secretsmanager:eu-central-1:${var.account_id}:secret:variables-QT5rhd:DB_PASSWORD::"
      #     },
      #     {
      #       name      = "OPEN_AI_API_KEY"
      #       valueFrom = "arn:aws:secretsmanager:eu-central-1:${var.account_id}:secret:variables-QT5rhd:OPEN_AI_API_KEY::"
      #     },
      #     {
      #       name      = "JWT_ISSUER_URI"
      #       valueFrom = "arn:aws:secretsmanager:eu-central-1:${var.account_id}:secret:variables-QT5rhd:JWT_ISSUER_URI::"
      #     },
      #     {
      #       name      = "AWS_CLIENT_ID"
      #       valueFrom = "arn:aws:secretsmanager:eu-central-1:${var.account_id}:secret:variables-QT5rhd:AWS_CLIENT_ID::"
      #     },
      #     {
      #       name      = "AWS_CLIENT_SECRET"
      #       valueFrom = "arn:aws:secretsmanager:eu-central-1:${var.account_id}:secret:variables-QT5rhd:AWS_CLIENT_SECRET::"
      #     },
      #     {
      #       name      = "DB_HOSTNAME"
      #       valueFrom = "arn:aws:secretsmanager:eu-central-1:${var.account_id}:secret:variables-QT5rhd:DB_HOSTNAME::"
      #     }
      #   ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "EcsStack-amazonecssampleTaskDefjavainternshipcontainerLogGroup6E5CDCE7-7MRlKTg61i3u"
          awslogs-region        = "eu-central-1"
          awslogs-stream-prefix = "amazon-ecs-sample"
        }
        secretOptions = []
      }
    }
  ])

  execution_role_arn       = "arn:aws:iam::${var.account_id}:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::${var.account_id}:role/ecsTaskRole"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

}
