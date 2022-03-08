output "ec2instance_1" {
  description = "The Public IP of EC2 Instance 1"
  value       = aws_instance.microservice_app.public_ip

}

output "dbinstance" {
  description = "The Database Server Public IP"
  value       = aws_instance.database.public_ip
}

output "load_balancer_instance" {
  description = "The Load_Balancer Server Public IP"
  value       = aws_instance.load_balancer.public_ip
}
