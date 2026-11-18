output "public_ip" {
  description = "IP publico da maquina"
  value       = aws_instance.web_server.public_ip
}

output "public_url" {
  description = "URL publica para entrega do MVP"
  value       = "http://${aws_instance.web_server.public_ip}"
}