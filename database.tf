# NOTE on name replace():
# Error: Error creating DB Instance: InvalidParameterValue: DBName must begin with a letter and contain only alphanumeric characters.
# forced to use a hyphen in ALBs, but the hyphen isn't allowed in the db name. so replace().

resource "aws_db_instance" "database" {
  identifier                          = "${var.project}-${var.environment}"
  allocated_storage                   = var.allocated_storage
  max_allocated_storage               = var.max_allocated_storage
  allow_major_version_upgrade         = true
  auto_minor_version_upgrade          = true
  multi_az                            = var.multi_az
  backup_retention_period             = var.backup_retention
  backup_window                       = var.backup_window
  ca_cert_identifier                  = "rds-ca-2019"
  maintenance_window                  = var.maintenance_window
  copy_tags_to_snapshot               = true
  deletion_protection                 = var.deletion_protection
  apply_immediately                   = var.apply_immediately
  storage_type                        = var.storage_type
  engine                              = "postgres"
  engine_version                      = var.engine_version
  iops                                = var.iops
  iam_database_authentication_enabled = true
  instance_class                      = var.instance
  name                                = replace(var.project, "-", "")
  username                            = "postgres"
  password                            = var.password
  performance_insights_enabled        = var.performance_insights
  parameter_group_name                = aws_db_parameter_group.parameters.name
  publicly_accessible                 = true
  storage_encrypted                   = true
  skip_final_snapshot                 = true
  kms_key_id                          = aws_kms_key.database.arn
  db_subnet_group_name                = aws_db_subnet_group.database.id
  enabled_cloudwatch_logs_exports = [
    "postgresql", "upgrade"
  ]
  vpc_security_group_ids = [
    aws_security_group.external_database_postgres_global.id
  ]

  tags = {
    Name                = "${var.project} database"
    terraform           = "true"
    project             = var.project
    environment         = var.environment
    deletion_protection = var.deletion_protection
  }

  depends_on = [
    aws_cloudwatch_log_group.postgresql
  ]

  # the DB stuff forces replacements and modularizing just makes it hard
  lifecycle {
    ignore_changes = [db_subnet_group_name, identifier, name]
  }
}

resource "aws_db_parameter_group" "parameters" {
  name        = "${var.project}-db-params-${var.environment}"
  family      = "postgres${var.parameter_family_version}"
  description = "deviations from default parameter group"

  parameter {
    name  = "log_min_duration_statement"
    value = "50"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }
  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  # necessary for pg_stat_statements to work
  # https://www.postgresql.org/docs/9.6/pgstatstatements.html
  parameter {
    name         = "shared_preload_libraries"
    value        = "auto_explain,pg_stat_statements"
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "track_activity_query_size"
    value        = "2048"
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "pg_stat_statements.track"
    value        = "all"
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "pg_stat_statements.max"
    value        = "5000"
    apply_method = "pending-reboot"
  }

  tags = {
    Name        = "${var.project} version ${var.parameter_family_version}"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}
