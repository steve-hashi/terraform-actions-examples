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
     events  = [before_create, before_update]
     actions = [action.external.fail]
    }
  }
}

action "external" "fail" {
  config {
    program = ["exit", "1"]
  }
}

action "external" "success" {
  config {
    program = ["echo", "Success from Action"]
  }
}
