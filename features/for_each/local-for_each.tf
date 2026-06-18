terraform {
//  required_version = "1.14.0-beta1"
  required_providers {
    external = {
      source = "hashicorp/local"
    }
  }
}

locals {
  regions = ["useast1", "uswest1", "eucentral1"]
}

resource "terraform_data" "region" {
  for_each = toset(local.regions)
  lifecycle {
    action_trigger {
      events = [after_create,after_update]
      actions = [action.local_command.region]
    }
  }
}

action "local_command" "region" {
  config {
    command = "/bin/echo"
    arguments = ["variable = ${resource.terraform_data.region[each.key]}}"]
  }
}
