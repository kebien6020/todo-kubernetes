data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = [
    "099720109477", # Canonical
  ]
}
