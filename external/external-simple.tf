terraform {
  required_version = "1.14.0-beta1"
  required_providers {
    external = {
      source = "registry.terraform.io/hashicorp/external"
    }
  }
}

resource "terraform_data" "fake_resource" {
  input = "fake-string"
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.external.test_after]
    }
  }
}

action "external" "test_after" {
  config {
    program = ["echo", "After!"]
  }
}
