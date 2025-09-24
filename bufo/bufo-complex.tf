terraform {
  required_providers {
    bufo = {
      source = "austinvalle/bufo"
    }
  }
}

resource "terraform_data" "test-all" {
//  count = 3
  lifecycle {
    action_trigger {
      events  = [before_create, after_create, before_update, after_update]
      actions = [action.bufo_print.awesome, action.bufo_print.bigeyes]
    }
  }
}

resource "terraform_data" "test-all-separate" {
  count = 3

  input = "bufu-test-${count.index}"

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.bufo_print.awesome]
    }
    action_trigger {
      events  = [after_create, after_update]
      actions = [action.bufo_print.bigeyes]
    }
  }
}

action "bufo_print" "awesome" {
  config {
    name = "awesomebufo"
  }
}

action "bufo_print" "bigeyes" {
  config {
    name= "bufo-big-eyes-stare"
  }
}

## Sample showing how to invoke an action 3x via -invoke
#  terraform apply -invoke=action.bufo_print.three
locals {
  foo = ["bufo-the-builder", "bufo-the-destroyer", "bufo-the-updater"]
}

action "bufo_print" "three" {
  config {
    name = local.foo[count.index]
  }
  count = 3
}

