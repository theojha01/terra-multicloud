resource "null_resource"​ "test1"​ {
 connection {
    type     = "ssh"​
    user     = "ec2-user"​
    private_key = file("C:/Users/Aakash/Downloads/terraform_trial.pem"​)
    host     = aws_instance.webserver1.public_ip
  }


 provisioner "remote-exec"​ {
    inline = [
      "sudo yum install http -y"​,
      "sudo yum install php -y"​,
      "sudo systemctl start httpd"​,
      "sudo systemctl start php"​,
      "cd /var/www/html"
  }
}
