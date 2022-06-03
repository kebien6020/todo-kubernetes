resource "aws_launch_template" "main" {
  instance_type          = "t3.medium"
  image_id               = data.aws_ami.ubuntu.id
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.main.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.main.id]
  }
}

resource "aws_security_group" "main" {
  name        = "kube-cluster-node"
  description = "Kube cluster node"
  vpc_id      = aws_vpc.vpc.id

  # Kube API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all communications between nodes
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Allow outbound to internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "cluster_token" {
  length = 16
}

resource "aws_instance" "kube-1" {
  launch_template {
    id = aws_launch_template.main.id
  }
  subnet_id = aws_subnet.pub-a.id

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      iam_instance_profile,
    ]
  }

  user_data = <<-EOT
  #!/bin/sh
  export K3S_TOKEN='${random_password.cluster_token.result}'
  export AWS_TOKEN=$(curl -fsS "http://169.254.169.254/latest/api/token" -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  export PUBLIC_IP=$(curl -fsS "http://169.254.169.254/latest/meta-data/public-ipv4" -H "X-aws-ec2-metadata-token: $AWS_TOKEN")
  export INSTALL_K3S_EXEC="--tls-san $PUBLIC_IP"
  curl -sfL https://get.k3s.io | sh -
  EOT
}

resource "aws_instance" "kube-2" {
  launch_template {
    id = aws_launch_template.main.id
  }
  subnet_id = aws_subnet.pub-b.id

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      iam_instance_profile,
    ]
  }

  user_data = <<-EOT
  #!/bin/sh
  export K3S_TOKEN='${random_password.cluster_token.result}'
  export K3S_URL='https://${aws_instance.kube-1.private_ip}:6443'
  curl -sfL https://get.k3s.io | sh -
  EOT
}
