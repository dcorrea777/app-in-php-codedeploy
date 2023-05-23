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

resource "aws_launch_template" "app" {
    name_prefix     = "template-"
    image_id        = data.aws_ami.ubuntu.id
    key_name        = data.aws_key_pair.app.key_name
    user_data       = base64encode(file("ec2_user_data.sh"))

    tags = {
        Name    = var.project_name,
        App     = var.project_name
    }

    iam_instance_profile {
        name = aws_iam_instance_profile.ec2_app.name
    }

    block_device_mappings {
        device_name = "/dev/sda1"
        ebs {
            volume_type = "gp3"
            volume_size = 50
        }
    }

    network_interfaces {
        associate_public_ip_address = true
        security_groups             = [aws_security_group.app.id]
    }
}

resource "aws_autoscaling_group" "app" {
    name_prefix         = "asg-"
    default_cooldown    = "300"
    max_size            = 4
    min_size            = 2
    vpc_zone_identifier = data.aws_subnets.app.ids

    tag {
        key                 = "Name"
        value               = var.project_name
        propagate_at_launch = true
    }

    tag {
        key                 = "App"
        value               = var.project_name
        propagate_at_launch = true
    }

    mixed_instances_policy {
        instances_distribution {
            on_demand_allocation_strategy            = "prioritized"
            on_demand_base_capacity                  = 100
            on_demand_percentage_above_base_capacity = 0
            spot_allocation_strategy                 = "capacity-optimized"
        }

        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.app.id
            }

            override {
                instance_type     = "t3.small"
            }

            override {
                instance_type     = "t3.medium"
            }
        }
    }
}

# resource "aws_instance" "app" {
#     ami                         = data.aws_ami.ubuntu.id
#     instance_type               = "t3.medium"
#     associate_public_ip_address = true
#     vpc_security_group_ids      = [aws_security_group.app.id]
#     subnet_id                   = data.aws_subnets.app.ids[0]
#     depends_on                  = [aws_security_group.app]
#     key_name                    = data.aws_key_pair.app.key_name
#     iam_instance_profile        = aws_iam_instance_profile.ec2_app.name
#     user_data                   = file("ec2_user_data.sh")

#     root_block_device {
#         delete_on_termination   = true
#         iops                    = 3000
#         volume_size             = 50
#         volume_type             = "gp3"
#     }

#     tags = {
#         Name    = var.project_name,
#         App     = var.project_name
#     }
# }
