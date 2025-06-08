# data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy " {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# data "aws_iam_policy" "AmazonSSMReadOnlyAccess " {
#   arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
# }

# data "aws_iam_policy_document" "get-secret-value " {
#   statement {
#     sid = "getSecretValue"
#     effect = "Allow"
#     actions = [ "secretsmanager:GetSecretValue" ]
#     resources = [ "arn:aws:secretsmanager:eu-central-1:${var.account_id}:secret:variables-QT5rhd" ]
#   }
# }

# resource "aws_iam_role" "ecs-deployment-role" {
#   name = "ecs-deployment-role"
#   managed_policy_arns = [ 
#      "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
#      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
#    ],
#    assume_role_policy = 
# }

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role_policy_attachment" "ecs_execution_secrets_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_role_s3_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}



