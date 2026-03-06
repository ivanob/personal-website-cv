#### This will contain the IAM role and policy for the GitHub Actions OIDC provider to assume 
### when deploying to AWS.

# This is the trust policy that allows GitHub Actions to assume the role. It specifies the conditions under which the role can be assumed, including the OIDC provider and the specific repository that can assume it.
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type        = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_username}/${var.github_repository}:*"
      ]
    }
  }
}

# This is the IAM role that GitHub Actions will assume when deploying. It uses the trust policy defined above.
resource "aws_iam_role" "github_deploy" {
  name = "github-actions-deploy"

  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

# This is the deployment permissions policy that allows the role to perform necessary actions for deployment, such as managing CloudFront distributions and S3 buckets.
data "aws_iam_policy_document" "github_deploy_permissions" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.github_username}.dev",
      "arn:aws:s3:::${var.github_username}.dev/*"
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = ["*"]

    effect = "Allow"
  }
}

# Finally I attach the permissions policy to the role, allowing GitHub Actions to perform the necessary actions for deployment when it assumes the role.
resource "aws_iam_role_policy" "github_deploy_policy" {
  name = "github-deploy-policy"
  role = aws_iam_role.github_deploy.id

  policy = data.aws_iam_policy_document.github_deploy_permissions.json
}