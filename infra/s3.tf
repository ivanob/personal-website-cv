resource "aws_s3_bucket" "personal_website" {
  bucket = "ivanobeso.dev"
  tags = {
    Name        = "ivanobeso.dev"
    Environment = "prod"
  }
}

# resource "aws_s3_bucket_cors_configuration" "personal_website_cors" {
#   bucket = aws_s3_bucket.personal_website.id
#   cors_rule {
#     allowed_origins = ["https://ivanobeso.dev", "https://www.ivanobeso.dev"]
#     allowed_methods = ["GET"]
#     allowed_headers = ["*"]
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }
# }

resource "aws_s3_bucket_public_access_block" "personal_website" {
  bucket                  = aws_s3_bucket.personal_website.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ACLs are completely disabled for that bucket. They are ignored by S3. Only IAM policies and bucket policies control access.
resource "aws_s3_bucket_ownership_controls" "personal_website" {
  bucket = aws_s3_bucket.personal_website.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Direct access to the bucket is blocked, only CloudFront can access it. This is the reason we dont need the CORS configuration. I will keep it commented out for now
# data "aws_iam_policy_document" "personal_website_oac" {
#   statement {
#     sid     = "AllowCloudFrontServicePrincipalReadOnly"
#     effect  = "Allow"
#     actions = ["s3:GetObject"]

#     resources = ["${aws_s3_bucket.personal_website.arn}/*"]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceArn"
#       values   = [aws_cloudfront_distribution.personal_website.arn]
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "personal_website" {
#   bucket = aws_s3_bucket.personal_website.id
#   policy = data.aws_iam_policy_document.personal_website_oac.json
# }

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.personal_website.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}