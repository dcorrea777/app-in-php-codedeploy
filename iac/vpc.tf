data "aws_vpc" "app" {
    id = var.vpc_id
}

data "http" "myip" {
    url = "http://ipv4.icanhazip.com"
}

data "aws_subnets" "app" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.app.id]
    }
}

resource "aws_security_group" "app" {
    name          = var.project_name
    description   = "Permite SSH e HTTP na instancia EC2"
    vpc_id        = data.aws_vpc.app.id

    ingress {
        description = "ssh"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    }

    ingress {
        description = "http"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    }

    ingress {
        description = "https"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    }    

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
