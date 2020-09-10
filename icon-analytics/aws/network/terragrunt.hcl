terraform {
  source = "github.com/insight-icon/terraform-icon-analytics-aws-network.git?ref=${local.vars.versions.network}"
}

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("variables.hcl")).locals
}

inputs = {
  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_key_paths = [local.vars.secrets.public_key_path]
}
