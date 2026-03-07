variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for ivanobeso.dev"
}

variable "github_username" {
  description = "GitHub username for OIDC provider condition"
}

variable "github_repository" {
  description = "GitHub repository name for OIDC provider condition"
}

variable "site_bucket_name" {
  type = string
}