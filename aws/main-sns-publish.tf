### Basic Usage
resource "aws_sns_topic" "example" {
  name = "example-topic"
}
action "aws_sns_publish" "example" {
  config {
    topic_arn = aws_sns_topic.example.arn
    message   = "Hello from Terraform!"
  }
}
resource "terraform_data" "example" {
  input = "trigger-message"
  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_sns_publish.example]
    }
  }
}

### Message with Subject
action "aws_sns_publish" "notification" {
  config {
    topic_arn = aws_sns_topic.alerts.arn
    subject   = "System Alert"
    message   = "Critical system event detected at ${timestamp()}"
  }
}

### JSON Message Structure
action "aws_sns_publish" "structured" {
  config {
    topic_arn         = aws_sns_topic.mobile.arn
    message_structure = "json"
    message = jsonencode({
      default = "Default message"
      email   = "Email version of the message"
      sms     = "SMS version"
      GCM = jsonencode({
        data = {
          message = "Push notification message"
        }
      })
    })
  }
}

### Message with Attributes
action "aws_sns_publish" "with_attributes" {
  config {
    topic_arn = aws_sns_topic.processing.arn
    message   = "Process this data"
    message_attributes {
      map_block_key = "priority"
      data_type     = "String"
      string_value  = "high"
    }
    message_attributes {
      map_block_key = "source"
      data_type     = "String"
      string_value  = "terraform"
    }
  }
}

### Deployment Notification
action "aws_sns_publish" "deploy_complete" {
  config {
    topic_arn = aws_sns_topic.deployments.arn
    subject   = "Deployment Complete"
    message = jsonencode({
      environment = var.environment
      version     = var.app_version
      timestamp   = timestamp()
      resources = {
        instances = length(aws_instance.app)
        databases = length(aws_db_instance.main)
      }
    })
  }
}
resource "terraform_data" "deploy_trigger" {
  input = var.deployment_id
  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_sns_publish.deploy_complete]
    }
  }
  depends_on = [aws_instance.app, aws_db_instance.main]
}