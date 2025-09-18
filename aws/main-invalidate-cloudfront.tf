### Basic Usage

resource "aws_cloudfront_distribution" "example" {
  # ... distribution configuration
}
action "aws_cloudfront_create_invalidation" "example" {
  config {
    distribution_id = aws_cloudfront_distribution.example.id
    paths           = ["/*"]
  }
}
resource "terraform_data" "example" {
  input = "trigger-invalidation"
  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_cloudfront_create_invalidation.example]
    }
  }
}

### Invalidate Specific Paths
action "aws_cloudfront_create_invalidation" "assets" {
  config {
    distribution_id = aws_cloudfront_distribution.example.id
    paths = [
      "/images/*",
      "/css/*",
      "/js/app.js",
      "/index.html"
    ]
    timeout = 1200 # 20 minutes
  }
}

### With Custom Caller Reference
action "aws_cloudfront_create_invalidation" "deployment" {
  config {
    distribution_id  = aws_cloudfront_distribution.example.id
    paths            = ["/*"]
    caller_reference = "deployment-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
    timeout          = 900
  }
}

### CI/CD Pipeline Integration
# Use this action in your deployment pipeline to invalidate cache after updating static assets:

# Trigger invalidation after S3 sync
resource "terraform_data" "deploy_complete" {
  input = local.deployment_id
  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_cloudfront_create_invalidation.post_deploy]
    }
  }
  depends_on = [aws_s3_object.assets]
}
action "aws_cloudfront_create_invalidation" "post_deploy" {
  config {
    distribution_id = aws_cloudfront_distribution.main.id
    paths = [
      "/index.html",
      "/manifest.json",
      "/static/js/*",
      "/static/css/*"
    ]
  }
}

### Environment-Specific Invalidation
locals {
  cache_paths = var.environment == "production" ? [
    "/api/*",
    "/assets/*"
  ] : ["/*"]
}
action "aws_cloudfront_create_invalidation" "env_specific" {
  config {
    distribution_id = aws_cloudfront_distribution.app.id
    paths           = local.cache_paths
    timeout         = var.environment == "production" ? 1800 : 900
  }
}