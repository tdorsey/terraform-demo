

resource "aws_s3_bucket_public_access_block" "default" {

  block_public_acls = var.block_public_acls
  block_public_policy = var.block_public_policy
  bucket = bucket
}



resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix
  bucket = var.bucket
  acl    = var.acl

    versioning {
        enabled = var.versioning
    }

    logging {
        target_bucket = var.target_bucket
        target_prefix = var.target_prefix
    }

    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_master_key_id
        sse_algorithm     = var.sse_algorithm
      }
    }
  }

    tags = var.tags
}