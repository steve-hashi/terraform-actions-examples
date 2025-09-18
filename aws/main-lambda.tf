resource "aws_lambda_function" "example" {
  # ... function configuration
}

action "aws_lambda_invoke" "example" {
  config {
    function_name = aws_lambda_function.example.function_name
    payload = jsonencode({
      key1 = "value1"
      key2 = "value2"
    })
  }
}

resource "terraform_data" "example" {
  input = "trigger-lambda"
  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_lambda_invoke.example]
    }
  }
}

### Invoke with Function Version
action "aws_lambda_invoke" "versioned" {
  config {
    function_name = aws_lambda_function.example.function_name
    qualifier     = aws_lambda_function.example.version
    payload = jsonencode({
      operation = "process"
      data      = var.processing_data
    })
  }
}

### Asynchronous Invocation
action "aws_lambda_invoke" "async" {
  config {
    function_name   = aws_lambda_function.worker.function_name
    invocation_type = "Event"
    payload = jsonencode({
      task_id = "background-job-${random_uuid.job_id.result}"
      data    = local.background_task_data
    })
  }
}

### Dry Run Validation
action "aws_lambda_invoke" "validate" {
  config {
    function_name   = aws_lambda_function.validator.function_name
    invocation_type = "DryRun"
    payload = jsonencode({
      config = var.validation_config
    })
  }
}


### With Log Capture
action "aws_lambda_invoke" "debug" {
  config {
    function_name = aws_lambda_function.debug.function_name
    log_type      = "Tail"
    payload = jsonencode({
      debug_level = "verbose"
      component   = "api-gateway"
    })
  }
}

### Mobile Application Context
action "aws_lambda_invoke" "mobile" {
  config {
    function_name = aws_lambda_function.mobile_backend.function_name
    client_context = base64encode(jsonencode({
      client = {
        client_id   = "mobile-app"
        app_version = "1.2.3"
      }
      env = {
        locale = "en_US"
      }
    }))
    payload = jsonencode({
      user_id = var.user_id
      action  = "sync_data"
    })
  }
}

### CI/CD Pipeline Integration
# Use this action in your deployment pipeline to trigger post-deployment functions:

# Trigger warmup after deployment
resource "terraform_data" "deploy_complete" {
  input = local.deployment_id
  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_lambda_invoke.warmup]
    }
  }
  depends_on = [aws_lambda_function.api]
}

action "aws_lambda_invoke" "warmup" {
  config {
    function_name = aws_lambda_function.api.function_name
    payload = jsonencode({
      action = "warmup"
      source = "terraform-deployment"
    })
  }
}

### Environment-Specific Processing
locals {
  processing_config = var.environment == "production" ? {
    batch_size = 100
    timeout    = 900
    } : {
    batch_size = 10
    timeout    = 60
  }
}

action "aws_lambda_invoke" "process_data" {
  config {
    function_name = aws_lambda_function.processor.function_name
    payload = jsonencode(merge(local.processing_config, {
      data_source = var.data_source
      environment = var.environment
    }))
  }
}

### Complex Payload with Dynamic Content
action "aws_lambda_invoke" "complex" {
  config {
    function_name = aws_lambda_function.orchestrator.function_name
    payload = jsonencode({
      workflow = {
        id    = "workflow-${timestamp()}"
        steps = var.workflow_steps
      }
      resources = {
        s3_bucket = aws_s3_bucket.data.bucket
        dynamodb  = aws_dynamodb_table.state.name
        sns_topic = aws_sns_topic.notifications.arn
      }
      metadata = {
        created_by  = "terraform"
        environment = var.environment
        version     = var.app_version
      }
    })
  }
}