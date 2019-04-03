terraform {
  required_version = "~> 0.10"

  backend "s3" {
    encrypt = true
    bucket  = "sbxopstrfstt001"
    key     = "terraformdatastore/terraform.tfstate"
    region  = "us-west-2"
  }
}
