resource "random_password" "mysql" {
  length  = 20
  special = false
}

resource "random_password" "postgres" {
  length  = 20
  special = false
}

# Security group: allow DB traffic ONLY from the EKS nodes
resource "aws_security_group" "db" {
  name        = "bedrock-db-sg"
  description = "Allow MySQL/Postgres only from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.node_security_group]
  }
  ingress {
    description     = "Postgres from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.node_security_group]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "bedrock-db-sg" })
}

resource "aws_db_subnet_group" "this" {
  name       = "bedrock-db-subnets"
  subnet_ids = var.private_subnets
  tags       = var.tags
}

resource "aws_db_instance" "mysql" {
  identifier             = "bedrock-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "catalog"
  username               = var.db_username
  password               = random_password.mysql.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags                   = merge(var.tags, { Name = "bedrock-mysql" })
}

resource "aws_db_instance" "postgres" {
  identifier             = "bedrock-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "orders"
  username               = var.db_username
  password               = random_password.postgres.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags                   = merge(var.tags, { Name = "bedrock-postgres" })
}

resource "aws_dynamodb_table" "carts" {
  name         = "bedrock-carts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = merge(var.tags, { Name = "bedrock-carts" })
}

resource "aws_ssm_parameter" "mysql_endpoint" {
  name  = "/bedrock/mysql/endpoint"
  type  = "String"
  value = aws_db_instance.mysql.address
  tags  = var.tags
}
resource "aws_ssm_parameter" "mysql_password" {
  name  = "/bedrock/mysql/password"
  type  = "SecureString"
  value = random_password.mysql.result
  tags  = var.tags
}
resource "aws_ssm_parameter" "postgres_endpoint" {
  name  = "/bedrock/postgres/endpoint"
  type  = "String"
  value = aws_db_instance.postgres.address
  tags  = var.tags
}
resource "aws_ssm_parameter" "postgres_password" {
  name  = "/bedrock/postgres/password"
  type  = "SecureString"
  value = random_password.postgres.result
  tags  = var.tags
}
