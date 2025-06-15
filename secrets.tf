resource "random_password" "mysql_password" {
  length           = 16
  special          = false
}

resource "aws_secretsmanager_secret" "mysql" {
  name        = "mysql-master-user-secret-3"
  description = "Master user credentials"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_secretsmanager_secret_version" "mysql_version" {
  secret_id = aws_secretsmanager_secret.mysql.id

  secret_string = jsonencode({
    username = "mysqlusername",
    password = random_password.mysql_password.result
  })
}