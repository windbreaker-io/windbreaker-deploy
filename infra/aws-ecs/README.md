# Windbreaker AWS ECS Infrastructure

A [terraform](https://www.terraform.io/) configuration for setting
up the infrastructure needed to run `windbreaker` on AWS ECS.

### Prerequisites

You'll need to have [terraform](https://www.terraform.io/) installed.

Afterwards, run `terraform init` and `terraform get` (from this project directory)
to pull down the modules necessary for deployment.

### Deploying the infrastructure

To deploy, run `terraform apply`. This will provision all of the parts needed
to start deploying `windbreaker` containers.

### Tear down

To deploy the ecs cluster, run `terraform destroy`. This will cleanly tear down all
resources that were spun up by the initial apply.

### Modifying the infrastructure

Simply make changes to the terraform configuration files and run `terraform apply`.
