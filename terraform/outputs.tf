output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.external-elb.dns_name
}

output "ec2instance_1" {
  description = "The Public IP of EC2 Instance 1"
  value       = aws_instance.microservice_app[0].public_ip

}

output "ec2instance_2" {
  description = "The Public IP of EC2 Instance 2"
  value       = aws_instance.microservice_app[1].public_ip

}

output "dbinstance" {
  description = "The Database Server Public IP"
  value       = aws_instance.database.public_ip
}
