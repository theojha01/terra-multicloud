provider "aws" {
  region = var.region
  shared_credentials_file = var.creds
  profile = "default"
}
