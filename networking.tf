# the name parameter is under ignore_changes because of issues with setting up
# modular terraform. some things can't be changed.

resource "aws_db_subnet_group" "database" {
  name       = "${var.project} ${var.environment}"
  subnet_ids = var.vpc_subnets

  tags = {
    Name        = "${var.project} database subnets"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}
