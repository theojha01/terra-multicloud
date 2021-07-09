provider "aws" {
  region = var.region
  shared_credentials_file = var.creds
  profile = "default"
}

resource "aws_instance" "os1" {
ami = "ami-010aff33ed5991201"
instance_type = "t2.micro"
security_groups = [ "launch-wizard-3" ]
 key_name = "terraform_trial"
 tags = {
  Name = "Webserver"
 }
}
