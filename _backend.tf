terraform {
  cloud {
    organization = "jawn"

    workspaces {
      name = "aws-iam"
    }
  }
}