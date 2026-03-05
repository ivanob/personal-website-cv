provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "site" {
  provider          = aws.use1
  domain_name       = "ivanobeso.dev"
  validation_method = "DNS"

  subject_alternative_names = ["www.ivanobeso.dev"]

  lifecycle {
    create_before_destroy = true
  }
}

# Creates validation records in Cloudflare instead of Route53
resource "cloudflare_record" "site_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = 60
}

resource "aws_acm_certificate_validation" "site" {
  provider                = aws.use1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for r in cloudflare_record.site_validation : r.hostname]
}