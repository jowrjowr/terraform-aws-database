
resource "aws_route53_record" "database_cname" {
  zone_id = data.terraform_remote_state.master_terraform.outputs.safeboda_zone_id
  name    = "db.${var.project}.${var.environment}.company.tld"
  type    = "CNAME"
  ttl     = "300"

  records = [
    aws_db_instance.database.address
  ]

  lifecycle {
    create_before_destroy = true
  }
}
