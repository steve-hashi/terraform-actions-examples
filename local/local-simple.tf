terraform {
//  required_version = "1.14.0-beta1"
  required_providers {
    external = {
      source = "hashicorp/local"
    }
  }
}

resource "terraform_data" "fake_resource" {
  input = "fake-string"
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.local_command.test_after]
    }
  }
}

action "local_command" "test_after" {
  config {
      command = "bash"
      arguments = ["example_script.sh", "Hi", "All!"]
      stdin = jsonencode({
        "key1" = "Hello "
        "key2" = "World!"
    })
  }
}
