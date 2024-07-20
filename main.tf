resource "aws_instance" "sample" {
  ami           = data.aws_ami.example.image_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_security_group.allow-all.id]

  tags = {
    Name = "image-ami"
  }
}


resource "null_resource" "null1" {

  connection {
      type     = "ssh"
      user     = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_user
      password = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_password
      host     = aws_instance.sample.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo pip3.11 install ansible hvac",
      "sudo pip3.11 install ansible-core"
    ]
  }
}

resource "aws_ami_from_instance" "example" {
  depends_on         = [null_resource.null1]
  name               = "golden-ami-${formatdate("DD-MM-YY", timestamp())}"
  source_instance_id = aws_instance.sample.id

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}