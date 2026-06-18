terraform {
# required_version = "1.16.0-alpha20260617"
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

resource "terraform_data" "data" {
  lifecycle {
		  action_trigger {
			  events = [after_create ]
			  actions = [action.local_command.create]
		  }
    }
  }

action "local_command" "create" {
  config {
    command = "/bin/echo"
    arguments = ["Create Success! caller.id=", caller.id]
  }
}