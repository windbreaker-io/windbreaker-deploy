# vpc
resource "aws_vpc" "ecs_cluster" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "ecs_cluster" {
  name = "vpc security group"
  description = "limit vpc ingress"
  vpc_id = "${aws_vpc.ecs_cluster.id}"
}

resource "aws_security_group_rule" "ingress_ssh" {
  type = "ingress"
  security_group_id = "${aws_security_group.ecs_cluster.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "ingress_default" {
  type = "ingress"
  security_group_id = "${aws_security_group.ecs_cluster.id}"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "ingress_https" {
  type = "ingress"
  security_group_id = "${aws_security_group.ecs_cluster.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "egress_all" {
  type = "egress"
  security_group_id = "${aws_security_group.ecs_cluster.id}"
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = [ "0.0.0.0/0" ]
}

# Gateways
resource  "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.ecs_cluster.id}"
}

resource "aws_nat_gateway" "gateway" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.id}"

  depends_on = [ "aws_internet_gateway.gateway" ]
}

# Public subnet
resource "aws_subnet" "public" {
  availability_zone = "${element(var.availability_zones, 0)}"
  vpc_id = "${aws_vpc.ecs_cluster.id}"
  cidr_block = "10.0.100.0/24"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.ecs_cluster.id}"
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route" "public" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gateway.id}"
}

# private subnets
resource "aws_subnet" "private" {
  count = "${length(var.availability_zones)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  vpc_id = "${aws_vpc.ecs_cluster.id}"
  cidr_block = "${format("10.0.%v.0/24", count.index + 1)}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.ecs_cluster.id}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.availability_zones)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route" "private" {
  count = "${length(var.availability_zones)}"
  route_table_id = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.gateway.*.id, count.index)}"
}

