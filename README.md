# My own personal portfolio site

This is a project created in Astro that displays my portfolio, skills, professional experience... and a link to my blog.

It is natively deployed into AWS, using github actions as CI/CD.

## Deployment

S3 (private) + CloudFront + ACM (TLS) + Cloudflare (DNS server)
…and a CI step that runs astro build and uploads dist/ to S3 + invalidates CloudFront.
I am not using route53 because Cloudflare already does the job and cloudflare Registrar does not allow you to change the authoritative nameservers to another DNS provider such as Amazon Route 53.
I wanted to keep it all within AWS, but also happens that Cloudflare is free and Route53 charges ~$0.50/month for the DNS server.

Cloudfront accesses the S3 container that stores the /dist build of the project and serves it. The ACM is needed cause nowadays all the browsers will flag the site as dangerous if I keep it only with HTTP, so I also need HTTPS. Even more, the .dev domains are handled by Google and HTTPS is mandatory.

## The user flow

```User → Cloudflare (DNS) → CloudFront (CDN) → S3 (files)```
- S3 stores my static files
- CloudFront serves them globally with HTTPS
   - ACM provides the SSL certificate (must be us-east-1)
- Cloudflare points my domain to CloudFront

what Cloudflare does is simply:
```
Domain query: "where is ivan-obeso.dev?"
        ↓
DNS server answers: "it's at xxx.cloudfront.net"
        ↓
Done!
```

## About the signing behaviour
The way that cloudfront access the private S3 bucket is by signing ***ALWAYS*** all the requests using the ***sigv4*** algorithm. This way nobody except cloudfront can access the S3 bucket that contains the static html of the page.

```
User request
    ↓
CloudFront receives it
    ↓
CloudFront signs the request with sigv4 (always)
    ↓
S3 verifies the signature came from YOUR CloudFront
    ↓
S3 returns the file
```

SigV4 (Signature Version 4) is AWS's algorithm for signing HTTP requests to prove they're legitimate. Every time cloudfront requests a file to the S3, SigV4 creates the Signature by hashing together:

- The HTTP method (GET)
- The URL path (/index.html)
- The headers
- The timestamp
- The AWS secret key

## Configuration
you need to create a terraform.tfvars in the infra folder with this content
```
cloudflare_api_token = "your_token"
cloudflare_zone_id   = "your_zone_id"
```
So it fetches from Cloudflare the data needed to issue the ACM certificate.

# Full sequence when I run terraform apply

```
terraform apply
      ↓
AWS: creates ACM certificate
      ↓
AWS: "prove you own ivanobeso.dev, add this CNAME"
      ↓
Cloudflare: Terraform adds the CNAME automatically ✅
      ↓
AWS: detects CNAME exists → certificate issued ✅
      ↓
AWS: CloudFront created with valid certificate ✅
      ↓
You: manually add CNAME in Cloudflare pointing to CloudFront
      ↓
🎉 Site is live!
```

what it creates in Cloudflare is:
```
1. CNAME record for ACM validation:
   _abc123.ivanobeso.dev → _xyz789.acm-validations.aws

2. (You'll need to add manually after apply):
   CNAME: ivanobeso.dev     → xxx.cloudfront.net
   CNAME: www.ivanobeso.dev → xxx.cloudfront.net
```
Cloudflare is only used for DNS records, all the infra is deployed in AWS.

# TODO
- put a description of experience in the Hero, and a link to the blog
- Add pictures to companies
- Add a gallery of images per Project