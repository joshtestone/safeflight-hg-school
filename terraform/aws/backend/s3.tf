resource "aws_s3_bucket" "terraform_backend" {
    bucket              = "${var.account_id}-terraform-backend"
    object_lock_enabled = true
    tags = {
      Name = "S3 Remote Terraform State Store for Atlantis"
      Terraform = "true"
      Workspace = "s3://457661787930-terraform-backend/terraform/aws/backend/${terraform.workspace}"
    }
}

resource "aws_s3_bucket_versioning" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.bucket

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "atlantis" {
  bucket = aws_s3_bucket.terraform_backend.id
  policy = data.aws_iam_policy_document.atlantis.json
}

data "aws_iam_policy_document" "atlantis" {
  statement {
    principals {
      type        = "AWS"
      #identifiers = ["arn:aws:iam::652180284939:role/${var.cluster_name}-atlantis-manager"]
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.terraform_backend.arn,
      "${aws_s3_bucket.terraform_backend.arn}/*",
    ]
  }
}
