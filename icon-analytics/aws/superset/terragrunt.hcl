terraform {
  source = "github.com/insight-infrastructure/terraform-aws-superset-docker.git?ref=${local.vars.versions.superset}"
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
  vpc_id = dependency.network.outputs.vpc_id
  subnet_id = dependency.network.outputs.public_subnets[0]

  instance_type = local.vars.environment.superset_instance_type

  superset_database_import_yaml_path = "${get_terragrunt_dir()}/../../../superset/sources/database_sources.yaml"

  additional_security_groups = [
    dependency.network.outputs.sg_rds_id,
    dependency.network.outputs.sg_redshift_id,
  ]
  hostname = "superset"
}
