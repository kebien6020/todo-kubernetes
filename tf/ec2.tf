resource "aws_launch_template" "main" {
  instance_type          = "t3.medium"
  image_id               = data.aws_ami.ubuntu.id
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.main.arn
  }

  network_interfaces {
    associate_public_ip_address = true
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
  }

  user_data = <<-EOT
  #!/bin/sh
  export K3S_TOKEN='${random_password.cluster_token.result}'
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
  }

  user_data = <<-EOT
  #!/bin/sh
  export K3S_TOKEN='${random_password.cluster_token.result}'
  export K3S_URL='https://${aws_instance.kube-1.private_ip}:6443'
  curl -sfL https://get.k3s.io | sh -
  EOT
}
