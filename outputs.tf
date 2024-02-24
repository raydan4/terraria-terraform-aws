output "terraria_server_public_ip" {
    description = "Public IP of terraria server"
    value = aws_instance.terraria_server.public_ip
}

output "terraria_world_backup_command" {
    description = "Command to backup terraria world"
    value = "ssh admin@${aws_instance.terraria_server.public_ip} sudo systemctl start terraria-world-backup.service"
}

output "terraria_server_status_command" {
    description = "Command to check the status of the terraria server"
    value = "ssh admin@${aws_instance.terraria_server.public_ip} sudo systemctl status terraria.service"
}
