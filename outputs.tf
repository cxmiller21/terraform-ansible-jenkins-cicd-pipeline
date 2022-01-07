output "VPC-ID-US-EAST-1" {
  value = aws_vpc.main.id
}

output "VPC-ID-US-EAST-2" {
  value = aws_vpc.worker.id
}

output "PEERING-CONNECTION-ID" {
  value = aws_vpc_peering_connection.useast1_useast2.id
}

output "Jenkins-Main-Private-IP" {
  value = aws_instance.jenkins_main.private_ip
}

output "Jenkins-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.jenkins_worker :
    instance.id => instance.public_ip
  }
}

output "Jenkins-Worker-Private-IPs" {
  value = {
    for instance in aws_instance.jenkins_worker :
    instance.id => instance.private_ip
  }
}

// output "Loadbalancer-DNS-URL" {
//   value = aws_lb.application.dns_name
// }
