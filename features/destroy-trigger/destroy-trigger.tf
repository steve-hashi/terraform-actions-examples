terraform {
# required_version = "1.16.0-alpha20260617"

  cloud {
    
    organization = "team-tf-actions-test-org"

    workspaces {
      name = "hcpt-tst-cli"
    }
  }
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
		  action_trigger {
			  events = [after_destroy]
			  actions = [action.local_command.destroy]
		  }
    }
  }

action "local_command" "create" {
  config {
    command = "/bin/echo"
    arguments = ["Create Success!"]
  }
}

action "local_command" "destroy" {
  config {
    command = "/bin/echo"
    arguments = ["Destroy Success!"]
  }
}
