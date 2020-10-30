output "password" {
  value = var.password
}

output "address" {
  value = aws_db_instance.database.address
}

output "port" {
  value = aws_db_instance.database.port
}

output "username" {
  value = aws_db_instance.database.username
}
