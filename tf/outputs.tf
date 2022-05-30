output "ami-name" {
  value = data.aws_ami.ubuntu.name
}

output "kube1-id" {
  value = aws_instance.kube-1.id
}
output "kube1-ip" {
  value = aws_instance.kube-1.public_ip
}
output "kube2-id" {
  value = aws_instance.kube-2.id
}
output "kube2-ip" {
  value = aws_instance.kube-2.public_ip
}
