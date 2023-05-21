data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "app" {
    key_name           = "dcorrea"
    include_public_key = true
}

resource "aws_instance" "app" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t3.medium"
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.app.id]
    subnet_id                   = data.aws_subnets.app.ids[0]
    depends_on                  = [aws_security_group.app]
    key_name                    = data.aws_key_pair.app.key_name
    iam_instance_profile        = aws_iam_instance_profile.ec2_app.name
    user_data                   = file("ec2_user_data.sh")

    root_block_device {
        delete_on_termination   = true
        iops                    = 3000
        volume_size             = 50
        volume_type             = "gp3"
    }

    tags = {
        Name    = var.project_name,
        App     = var.project_name
    }
}
