variable "block_dump_bucket" {}

module "block_dump" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.block_dump_bucket
  acl    = "private"

  versioning = {
    enabled = true
  }
}
