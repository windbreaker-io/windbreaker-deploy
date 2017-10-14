resource "aws_key_pair" "key_pair" {
  key_name = "${var.cluster_name}-key-pair"
  public_key = "${file(var.ssh_public_key_file)}"
}
