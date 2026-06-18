terraform {
//  required_version = "1.14.0-beta1"
  required_providers {
    bufo = {
      source = "austinvalle/bufo"
    }
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

