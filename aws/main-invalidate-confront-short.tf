# Trigger invalidation after S3 sync
resource "terraform_data" "deploy_complete" {
  input = aws_cloudfront_distribution.main.id
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