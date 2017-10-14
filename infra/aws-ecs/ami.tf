# grab latest coreos image
module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_coreos_ami"
  region = "us-east-1"
  channel = "stable"
  virttype = "hvm"
}

