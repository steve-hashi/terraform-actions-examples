terraform {
  required_version = "1.14.0-beta1"
  required_providers {
    bufo = {
      source = "austinvalle/bufo"
    }
  }
}

resource "terraform_data" "test" {
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.bufo_print.success]
    }
  }
}

action "bufo_print" "success" {
  config {
    # random colorized bufo
    color = true
  }
}
