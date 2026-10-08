output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.project-vpc.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.server.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.server.public_ip
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.server.private_ip
}

output "ssh_command" {
  description = "SSH command"
  value       = "ssh -i <your-key.pem> ubuntu@${aws_instance.server.public_ip}"
}
