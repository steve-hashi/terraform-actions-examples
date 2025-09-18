### Basic Usage
resource "aws_ses_email_identity" "example" {
  email = "sender@example.com"
}
action "aws_ses_send_email" "example" {
  config {
    source       = aws_ses_email_identity.example.email
    subject      = "Test Email"
    text_body    = "This is a test email sent from Terraform."
    to_addresses = ["recipient@example.com"]
  }
}
resource "terraform_data" "example" {
  input = "send-notification"
  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_ses_send_email.example]
    }
  }
}

### HTML Email with Multiple Recipients
action "aws_ses_send_email" "newsletter" {
  config {
    source             = aws_ses_email_identity.marketing.email
    subject            = "Monthly Newsletter - ${formatdate("MMMM YYYY", timestamp())}"
    html_body          = "<h1>Welcome!</h1><p>This is our <strong>monthly newsletter</strong>.</p>"
    to_addresses       = var.subscriber_emails
    cc_addresses       = ["manager@example.com"]
    reply_to_addresses = ["support@example.com"]
    return_path        = "bounces@example.com"
  }
}

### Deployment Notification
action "aws_ses_send_email" "deploy_notification" {
  config {
    source       = "deployments@example.com"
    subject      = "Deployment Complete: ${var.environment}"
    text_body    = "Application ${var.app_name} has been successfully deployed to ${var.environment}."
    to_addresses = var.team_emails
  }
}
resource "terraform_data" "deployment" {
  input = var.deployment_id
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aws_ses_send_email.deploy_notification]
    }
  }
  depends_on = [aws_instance.app]
}

### Alert Email with Dynamic Content
locals {
  alert_body = templatefile("${path.module}/templates/alert.txt", {
    service     = var.service_name
    environment = var.environment
    timestamp   = timestamp()
    details     = var.alert_details
  })
}
action "aws_ses_send_email" "alert" {
  config {
    source       = "alerts@example.com"
    subject      = "ALERT: ${var.service_name} Issue Detected"
    text_body    = local.alert_body
    to_addresses = var.oncall_emails
    cc_addresses = var.manager_emails
  }
}

### Multi-format Email
action "aws_ses_send_email" "welcome" {
  config {
    source    = aws_ses_email_identity.noreply.email
    subject   = "Welcome to ${var.company_name}!"
    text_body = "Welcome! Thank you for joining us. Visit our website for more information."
    html_body = templatefile("${path.module}/templates/welcome.html", {
      user_name    = var.user_name
      company_name = var.company_name
      website_url  = var.website_url
    })
    to_addresses = [var.user_email]
  }
}

### Conditional Email Sending
action "aws_ses_send_email" "conditional" {
  config {
    source       = "notifications@example.com"
    subject      = var.environment == "production" ? "Production Alert" : "Test Alert"
    text_body    = "This is a ${var.environment} environment notification."
    to_addresses = var.environment == "production" ? var.prod_emails : var.dev_emails
  }
}

### Batch Processing Notification
action "aws_ses_send_email" "batch_complete" {
  config {
    source       = "batch-jobs@example.com"
    subject      = "Batch Processing Complete - ${var.job_name}"
    html_body    = <<-HTML
      <h2>Batch Job Results</h2>
      <p><strong>Job:</strong> ${var.job_name}</p>
      <p><strong>Records Processed:</strong> ${var.records_processed}</p>
      <p><strong>Duration:</strong> ${var.processing_duration}</p>
      <p><strong>Status:</strong> ${var.job_status}</p>
    HTML
    to_addresses = var.admin_emails
  }
}