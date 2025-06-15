resource "random_password" "mysql_password" {
  length           = 16
  special          = false
}

resource "aws_secretsmanager_secret" "mysql" {
  name        = "mysql-master-user-secret-${random_string.suffix.result}"
  description = "Master user credentials"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_secretsmanager_secret_version" "mysql_version" {
  secret_id = aws_secretsmanager_secret.mysql.id

  secret_string = jsonencode({
    username = "mysqlusername",
    password = random_password.mysql_password.result
  })
}