# Add the new EC2 instance to the inventory
resource "aap_host" "host" {
  for_each     = { for idx, instance in aws_instance.web_server : idx => instance }
  inventory_id = data.aap_inventory.inventory.id
  groups = toset([resource.aap_group.tfademo.id])
  name         = each.value.public_ip
  description  = "Host provisioned by Terraform"
  variables    = jsonencode({
    ansible_user = "ec2-user"
    public_ip    = each.value.public_ip
    target_hosts = each.value.public_ip
  })
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aap_eda_eventstream_post.update]
    }
  }
}

# TF action to run the update AWS provisioning job (after the hosts get added to AAP inventory)
action "aap_eda_eventstream_post" "update" {
  config {
    limit = "tfademo"
    template_type = "job"
    job_template_name = "Update AWS Provisioning Job"
    organization_name = "Default"

    event_stream_config = {
      url = var.aap_eventstream_url
      username = var.tf-es-username
      password = var.tf-es-password
    }
  }
}