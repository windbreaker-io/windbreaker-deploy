provider "aws" {
  region = "${var.region}"
}

provider "template" {
  version = "~> 0.1"
}
