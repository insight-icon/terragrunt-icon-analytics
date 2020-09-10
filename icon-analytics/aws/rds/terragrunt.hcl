terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-rds.git?ref=v2.15.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("variables.hcl")).locals
  network = find_in_parent_folders("network")
}

dependencies {
  paths = [local.network]
}

dependency "network" {
  config_path = local.network
}

inputs = {
  identifier = "icon-analytics-main-${local.vars.env}"
  name = "main${local.vars.env}"
  final_snapshot_identifier = "icon-main-${local.vars.env}"

  publicly_accessible = true # TODO change in prod?

  subnet_ids = dependency.network.outputs.public_subnets
  vpc_security_group_ids = [dependency.network.outputs.sg_rds_id]

  allocated_storage = 200

  engine            = "postgres"
  family = "postgres12"
  major_engine_version = "12"
  engine_version    = "12.3"

  instance_class    = "db.t2.medium"

  allocated_storage = 5
  storage_encrypted = false

  username = local.vars.secrets.rds_admin_user
  password = local.vars.secrets.rds_admin_password
  port     = "5432"

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 0

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  deletion_protection = false
}


