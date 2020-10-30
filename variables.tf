variable "environment" {
  description = "environment name"
  default     = "dev"
  type        = string
}

variable "project" {
  description = "project tag"
  type        = string
}

variable "vpc_id" {
  description = "VPC id to build the database in"
  type        = string
}

variable "vpc_subnets" {
  description = "list of VPC subnet ids"
  type        = list(string)
}

variable "deletion_protection" {
  description = "protect assets from accidental purging?"
  default     = false
  type        = bool
}

variable "maintenance_window" {
  description = "when AWS maintenance can occur (UTC)"
  default     = "Mon:00:00-Mon:02:00"
  type        = string
}

variable "apply_immediately" {
  description = "whether to do disruptive things NOW"
  default     = true
  type        = bool
}

# database configuration

variable "multi_az" {
  description = "database multi az redundancy"
  default     = false
  type        = bool
}

variable "engine_version" {
  description = "database engine version"
  default     = "11.5"
  type        = string
}

variable "parameter_family_version" {
  description = "database parameter version. distinct from engine version."
  default     = "11"
  type        = string
}

variable "backup_retention" {
  description = "backup retention time"
  default     = 1
  type        = number
}

variable "backup_window" {
  description = "daily backup time in UTC"
  default     = "23:00-00:00"
  type        = string
}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
variable "instance" {
  description = "database instance type"
  type        = string
}

variable "password" {
  description = "root database password"
  type        = string
}

variable "storage_type" {
  default = "gp2"
  type    = string
}

variable "allocated_storage" {
  description = "how much storage in GB to start with"
  default     = 50
  type        = number
}

variable "max_allocated_storage" {
  description = "how much storage in GB are we willing to ever allow?"
  default     = 1000
  type        = number
}

variable "iops" {
  description = "database reserved iops - overrides storage_type by setting"
  default     = 0
  type        = number
}

variable "performance_insights" {
  description = "whether it is enabled or not"
  default     = true
  type        = bool
}

variable "database_alarms" {
  description = "whether it is enabled or not"
  default     = true
  type        = bool
}
