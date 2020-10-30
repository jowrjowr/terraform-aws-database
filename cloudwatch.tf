# cloudwatch log groups are created whether we like it or not, so the best thing
# to do is manage them so they don't hold stuff forever.

resource "aws_cloudwatch_log_group" "postgresql" {
  name              = "/aws/rds/instance/${var.project}-${var.environment}/postgresql"
  retention_in_days = 7
  tags = {
    Name        = "database log"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "upgrade" {
  name              = "/aws/rds/instance/${var.project}-${var.environment}/upgrade"
  retention_in_days = 7
  tags = {
    Name        = "database upgrade log"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  count               = var.database_alarms ? 1 : 0
  alarm_name          = "${var.project}_${var.environment}_database_cpu"
  alarm_description   = "${var.environment} DB CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  threshold           = "75"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "cpu"
    return_data = "true"
    metric {
      metric_name = "CPUUtilization"
      namespace   = "AWS/RDS"
      period      = "120"
      stat        = "Maximum"
      dimensions = {
        DBInstanceIdentifier = aws_db_instance.database.identifier
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.project} database cpu utilization"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "database_free_space" {
  count               = var.database_alarms ? 1 : 0
  alarm_name          = "${var.project}_${var.environment}_database_free_space"
  alarm_description   = "${var.environment} DB Free Space%"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  threshold           = "0.25"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "space_percent"
    expression  = "space/${aws_db_instance.database.max_allocated_storage}"
    label       = "Percentage of total space"
    return_data = "true"
  }

  metric_query {
    id = "space"
    metric {
      metric_name = "FreeStorageSpace"
      namespace   = "AWS/RDS"
      period      = "120"
      unit        = "Megabytes"
      stat        = "Maximum"
      dimensions = {
        DBInstanceIdentifier = aws_db_instance.database.identifier
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.project} database free space"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "database_burst_balance" {
  count               = var.database_alarms ? 1 : 0
  alarm_name          = "${var.project}_${var.environment}_database_burst_balance"
  alarm_description   = "${var.environment} DB IO Burst Balance %"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  threshold           = "50"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "burstbalance"
    return_data = "true"
    metric {
      metric_name = "BurstBalance"
      namespace   = "AWS/RDS"
      period      = "120"
      stat        = "Minimum"
      dimensions = {
        DBInstanceIdentifier = aws_db_instance.database.identifier
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.project} database burst balance"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

# have to keep an eye on this one
# ~2.1 billion is death.
# see: https://aws.amazon.com/blogs/database/implement-an-early-warning-system-for-transaction-id-wraparound-in-amazon-rds-for-postgresql/

resource "aws_cloudwatch_metric_alarm" "database_largest_transaction_id" {
  count               = var.database_alarms ? 1 : 0
  alarm_name          = "${var.project}_${var.environment}_database_largest_transaction_id"
  alarm_description   = "${var.environment} DB Largest Transaction ID"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "1250000000"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "transaction_id"
    return_data = "true"
    metric {
      metric_name = "MaximumUsedTransactionIDs"
      namespace   = "AWS/RDS"
      period      = "120"
      stat        = "Average"
      dimensions = {
        DBInstanceIdentifier = aws_db_instance.database.identifier
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.project} database transaction ID"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

# may be overkill to do both read and write?

resource "aws_cloudwatch_metric_alarm" "database_write_latency" {
  count               = var.database_alarms ? 1 : 0
  alarm_name          = "${var.project}_${var.environment}_database_write_latency"
  alarm_description   = "${var.environment} DB Write Latency (seconds)"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "0.15"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "latency"
    return_data = "true"
    metric {
      metric_name = "WriteLatency"
      namespace   = "AWS/RDS"
      period      = "120"
      stat        = "Average"
      dimensions = {
        DBInstanceIdentifier = aws_db_instance.database.identifier
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.project} database write latency"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "database_read_latency" {
  count               = var.database_alarms ? 1 : 0
  alarm_name          = "${var.project}_${var.environment}_database_read_latency"
  alarm_description   = "${var.environment} DB Read Latency (seconds)"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "0.05"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "latency"
    return_data = "true"
    metric {
      metric_name = "ReadLatency"
      namespace   = "AWS/RDS"
      period      = "120"
      stat        = "Average"
      dimensions = {
        DBInstanceIdentifier = aws_db_instance.database.identifier
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.project} database read latency"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}
