/*
// importing required modules start
// vpc+sg start 
module "aws_vpc" {
    source = "../aws_vpc/"
}
// vpc+sg end

// efs start
module "efs" {
    source = "../efs/"
}
// efs end
// importing required modules end
*/

// authentication key creation and upload starts
resource "tls_private_key" "ssh_key_gen" {
  algorithm   = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "new_key_pair" {
  depends_on = [
		tls_private_key.ssh_key_gen
  ]
  key_name   = "new_key_pair"
  public_key = tls_private_key.ssh_key_gen.public_key_openssh
}

resource "local_file" "private_file_1" {
  depends_on = [
     aws_key_pair.new_key_pair
  ]

  content  = tls_private_key.ssh_key_gen.private_key_pem
  filename = "new_key_pair.pem"

  provisioner "local-exec" {
       command= "chmod 400 new_key_pair.pem"
  }

}
// authentication key creation and upload ends

// creating ec2 instance start
resource "aws_instance" "ec2_for_efs" {
  depends_on = [
    module.aws_vpc,
    module.efs,
    local_file.private_file_1
  ]
  ami           = "ami-0732b62d310b80e97"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ module.aws_vpc.public_sg_id ]
  key_name = aws_key_pair.new_key_pair.key_name
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "new_key_pair"
    host     = aws_instance.ec2_for_efs.public_ip
  }
  provisioner "remote-exec" {
    inline = [
	  "sudo yum install httpd git php amazon-efs-utils nfs-utils -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }
  tags = {
    Name = "ec2_for_efs"
  }
}
// creating ec2 instance end

// mounting efs on ec2 start
resource "null_resource" "mounting" {

depends_on = [aws_instance.ec2_for_efs]

  connection {
    type              = "ssh"
    user              = "ec2-user"
    private_key 	    = "new_key_pair.pem"
    host              = aws_instance.ec2_for_efs.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo ${module.efs.efs_dns_name}:/var/www/html efs defaults,_netdev 0 0 >> sudo /etc/fstab",
      "sudo mount  ${module.efs.efs_dns_name}:/  /var/www/html",
      "sudo rm  -rf  /var/www/html/*",
    ]
  }
}
// mounting efs on ec2 end