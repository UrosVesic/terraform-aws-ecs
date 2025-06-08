resource "aws_security_group" "db_sg" {
  name   = "Database-SG"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.task_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-subnet-group"
  subnet_ids = module.vpc.database_subnets
}

resource "aws_db_instance" "mysql" {
  identifier              = "mysqlinstance"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "socnetdb"
  username                = jsondecode(aws_secretsmanager_secret_version.mysql_version.secret_string)["username"]
  password                = jsondecode(aws_secretsmanager_secret_version.mysql_version.secret_string)["password"]
  db_subnet_group_name    = aws_db_subnet_group.mysql.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
}
