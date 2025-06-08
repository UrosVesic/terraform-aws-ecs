module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "social-network-bucket-${var.account_id}"

}

resource "aws_iam_policy" "s3_full_access" {
  name        = "socialNetworkS3FullAccess"
  description = "Allow full access to specific S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:*"],
      Resource = [
        module.s3_bucket.s3_bucket_arn,
        "${module.s3_bucket.s3_bucket_arn}/*",
      ]
    }]
  })
}
