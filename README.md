# My own personal portfolio site

This is a project created in Astro that displays my portfolio, skills, professional experience... and a link to my blog.

It is natively deployed into AWS, using github actions as CI/CD.

## Deployment

S3 (private) + CloudFront + ACM (TLS) + Route 53 (DNS)
…and a CI step that runs astro build and uploads dist/ to S3 + invalidates CloudFront.

Cloudfront accesses the S3 container that stores the /dist build of the project and serves it. The ACM is needed cause nowadays all the browsers will flag the site as dangerous if I keep it only with HTTP, so I also need HTTPS. Even more, the .dev domains are handled by Google and HTTPS is mandatory.

## The user flow

```User → Route53 (DNS) → CloudFront (CDN) → S3 (files)```
- S3 stores my static files
- CloudFront serves them globally with HTTPS
   - ACM provides the SSL certificate (must be us-east-1)
-  Route53 points my domain to CloudFront