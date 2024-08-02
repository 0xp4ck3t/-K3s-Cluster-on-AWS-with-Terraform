# --- compute/main.tf ---

data "aws_ami" "server-ami" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "random_id" "k3_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "k3_auth" {
  public_key = file(var.public_key_path)
  key_name   = var.key_name
}

resource "aws_instance" "k3_node" {
  count         = var.instance_count # 1
  instance_type = var.instance_type
  ami           = data.aws_ami.server-ami.id
  tags = {
    Name = "k3-node-${random_id.k3_node_id[count.index].dec}"
  }
  key_name               = aws_key_pair.k3_auth.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]
  user_data = templatefile(var.user_data_path,
    {
      nodename    = "k3-node-${random_id.k3_node_id[count.index].dec}"
      db_endpoint = var.db_endpoint
      dbuser      = var.dbuser
      dbpass      = var.dbpassword
      dbname      = var.dbname
  })
  root_block_device {
    volume_size = var.vol_size #10
  }

}

resource "aws_alb_target_group_attachment" "k3-tg-at" {
  count            = var.instance_count
  target_group_arn = var.tg_arn
  target_id        = aws_instance.k3_node[count.index].id
  port             = var.tg_port
}

