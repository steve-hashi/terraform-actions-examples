
# Provision the AWS EC2 instance(s)
resource "aws_instance" "web_server" {
  count                     = 5
  ami                       = "ami-0dfc569a8686b9320" # Red Hat Enterprise Linux
  instance_type             = "t2.micro"
  key_name                  = var.ssh_key_name
  vpc_security_group_ids    = [aws_security_group.allow_http_ssh.id]
  associate_public_ip_address = true
  tags = {
    Name = "hcp-terraform-aap-demo-${count.index + 1}"
  }  
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aap_eda_eventstream_post.configure]
    }
  }
}

# TF action to run the new AWS provisioning workflow (after ec2 instance are created)
action "aap_eda_eventstream_post" "configure" {
  config {
    limit = "tfademo"
    template_type = "job"
    job_template_name = "New AWS Provisioning Workflow"
    organization_name = "Default"

    event_stream_config = {
      url = var.aap_eventstream_url
      username = var.tf-es-username
      password = var.tf-es-password
    }
  }
}