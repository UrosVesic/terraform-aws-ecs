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


