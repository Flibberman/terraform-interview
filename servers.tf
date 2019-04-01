data "aws_ami" "amazon_windows_2019" {
    most_recent = true

    filter {
        name = "name"
        values = ["Windows_Server-2019-English-Full-Base-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["amazon"]
}

resource "aws_instance" "webhead" {
   ami = "${data.aws_ami.amazon_windows_2019.image_id}"
   subnet_id = "subnet-636df004"
   instance_type = "t2.medium"
   ebs_optimized = "false"
   key_name = "SBXOPSINFKEY"
   get_password_data = "true"
   vpc_security_group_ids= ["sg-46e5ee3e","sg-084a5670"]
   tags {
     Environment = "ENV"
     Location = "SBX"
     Name = "TSTENVPLAWEB001"
     Role = "PLA"
     Service = "WEB"
     StackNode = "001"
   }
   root_block_device {
        volume_size = 100
        volume_type = "gp2"
   }
}