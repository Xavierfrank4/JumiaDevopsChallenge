output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.external-elb.dns_name
}

output "ec2instance" {
  description = "The Public IP of EC2 Instances"
  value       = aws_instance.microservice_app[0].public_ip

}
