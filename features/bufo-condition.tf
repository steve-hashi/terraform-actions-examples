terraform {
#  required_version = "1.14.0-beta1"
  required_providers {
    bufo = {
      source = "austinvalle/bufo"
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

resource "terraform_data" "test" {
	count = 3
	name = "item-${count.index}"
	lifecycle {
		action_trigger {
			events = [after_create]
			condition = count.index == 1
			actions = [action.bufo_print.awesome]
		}
		action_trigger {
			events = [after_update]
			condition = count.index == 2
			actions = [action.test_action.success]
		}
	}
}