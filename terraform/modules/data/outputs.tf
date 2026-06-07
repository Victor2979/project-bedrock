output "mysql_endpoint"    { value = aws_db_instance.mysql.address }
output "postgres_endpoint" { value = aws_db_instance.postgres.address }
output "dynamodb_table"    { value = aws_dynamodb_table.carts.name }
