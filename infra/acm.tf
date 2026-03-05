
provider "aws" {
  alias  = "use1"
  region = "us-east-1" # REQUIRED for CloudFront ACM certs
}

###############################################################################
# ACM certificate in us-east-1 (for CloudFront)
###############################################################################
resource "aws_acm_certificate" "site" {
  provider          = aws.use1
  domain_name       = "ivan-obeso.dev"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.ivan-obeso.dev",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# Create DNS validation records in Route 53
###############################################################################
resource "aws_route53_record" "site_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.personal_domain.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

###############################################################################
# Tell ACM to check the DNS records and finalize validation
###############################################################################
resource "aws_acm_certificate_validation" "site" {
  provider                = aws.use1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for r in aws_route53_record.site_validation : r.fqdn]
}