provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

data "terraform_remote_state" "master_terraform" {
  backend = "remote"

  config = {
    organization = "ORGANIZATION"
    workspaces = {
      name = "WORKSPACE"
    }
  }
}
