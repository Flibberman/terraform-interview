data "aws_ami" "amazon_windows_2019" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "webheads" {
  count                  = "2"
  ami                    = "${data.aws_ami.amazon_windows_2019.image_id}"
  subnet_id              = "subnet-636df004"
  instance_type          = "t2.medium"
  ebs_optimized          = "false"
  key_name               = "SBXOPSINFKEY"
  get_password_data      = "true"
  vpc_security_group_ids = ["sg-46e5ee3e", "sg-084a5670"]

  user_data = <<EOF
  <powershell>
  Enable-PSRemoting -Force
  Set-ExecutionPolicy RemoteSigned –Force

  Import-Module ServerManager
  Add-WindowsFeature Web-Server -IncludeAllSubFeature
  Add-WindowsFeature Web-Mgmt-Tools
  Add-WindowsFeature NET-Framework-Features, NET-Framework-Core
  </powershell>
  EOF

  tags {
    Environment = "ENV"
    Location    = "SBX"
    Name        = "SBXENVPLAWEB00${count.index + 1}"
    Role        = "PLA"
    Service     = "WEB"
  }

  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }
}

resource "aws_elb" "load_balancer" {
  name               = "SBXENVPLALB001"
  availability_zones = ["us-west-2a", "us-west-2b"]
  internal           = false
  security_groups    = ["sg-46e5ee3e", "sg-084a5670"]
  subnets            = ["${aws_subnet.public.*.id}"]

  tags {
    Environment = "ENV"
    Location    = "SBX"
    Name        = "SBXENVPLALB001"
    Role        = "PLA"
    Service     = "LB"
  }

}