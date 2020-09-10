variable "block_dump_bucket" {}

module "block_dump" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.block_dump_bucket
  acl    = "private"

  versioning = {
    enabled = true
  }
}

variable "airflow_instance_profile_name" {}
variable "env" {}

resource "aws_iam_policy" "s3_put_logs_policy" {
  name   = "S3PutLogsPolicy${title(var.env)}"
  policy = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid":"ReadWrite",
          "Effect":"Allow",
          "Action":["s3:GetObject", "s3:PutObject", "s3:ListObjects", "s3:ListObjectsV2"],
          "Resource":["${module.block_dump.this_s3_bucket_arn}/*"]
        }
    ]
}
EOT
}

data "aws_iam_instance_profile" "airflow" {
  name = var.airflow_instance_profile_name
}

resource "aws_iam_role_policy_attachment" "s3_put_logs_policy" {
  role       = data.aws_iam_instance_profile.airflow.role_name
  policy_arn = aws_iam_policy.s3_put_logs_policy.arn
}
