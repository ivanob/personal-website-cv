resource "aws_route53_zone" "personal_domain" {
  name = "ivan-obeso.dev"

  tags = {
    Name        = "ivan-obeso.dev"
    Environment = "prod"
  }
}