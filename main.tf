provider "aws" {
  alias   = "us-east-2"
  region  = "us-east-2"
  version = "2.22.0"
}

terraform {
  required_version = "= 0.12.19"
}

