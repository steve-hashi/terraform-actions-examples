terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias = "east"
  region = "us-east-1"
}

provider "aws" {
  alias = "west"
  region = "us-west-2"
}

resource "aws_instance" "west" {
  provider = aws.west
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aws_lambda_invoke.east]
    }
  }
}

action "aws_lambda_invoke" "east" {
  # TODO: Does this call west due to resourece reference or default to east?
  provider  = aws.east
}
