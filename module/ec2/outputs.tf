output "ec2_details" {
  value = [
    for key, instance in aws_instance.this: {
      id = instance.id
      public_ip = instance.public_ip
      private_ip = instance.private_ip
    }
  ]
}