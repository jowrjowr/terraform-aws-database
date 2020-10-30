# it is all public anyway until these can be buried in a private subnet.

resource "aws_security_group" "external_database_postgres_global" {
  name        = "database external access"
  description = "postgresql access"
  vpc_id      = var.vpc_id

  ingress {
    description = "global ipv4 access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "external_database_postgres_global"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}
