terraform {
# required_version = "1.16.0-alpha20260617"

/*  cloud {
    
    organization = "team-tf-actions-test-org"

    workspaces {
      name = "hcpt-tst-cli"
    }
  } */
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

resource "terraform_data" "data" {
  count = 1
  lifecycle {
		  action_trigger {
			  events = [after_create]
			  actions = [action.local_command.create, action.local_command.fail]
        on_failure = continue
		  }
		  action_trigger {
			  events = [after_create]
			  actions = [action.local_command.create, action.local_command.fail]
        on_failure = taint
		  }
		  action_trigger {
			  events = [after_create]
			  actions = [action.local_command.create, action.local_command.fail]
        on_failure = continue
		  }
    }
  }

action "local_command" "create" {
  config {
    command = "/bin/echo"
    arguments = ["Create Success!"]
  }
}

action "local_command" "fail" {
  config {
      command = "bash"
      arguments = ["example_script.sh", 1, "Failed!"]
      stdin = jsonencode({
        "key1" = "Failed !"
    })
  }
}
