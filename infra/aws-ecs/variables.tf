variable "cluster_name" {
  description = "the name of the cluster to launch"
  default = "ecs_cluster"
}

variable "ssh_public_key_file" {
  description = "The public key file"
  default = "~/.ssh/id_rsa.pub"
}

variable "region" {
  description = "The region to launch in"
  default = "us-east-1"
}

variable "availability_zones" {
  description = "The availability zones to launch in"
  default = [ "us-east-1a" ]
}
