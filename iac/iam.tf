resource "aws_iam_role" "ec2_app" {
    name = "ec2-${var.project_name}"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {
                Service = "ec2.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_instance_profile" "ec2_app" {
    name = "profile-${var.project_name}"
    role = aws_iam_role.ec2_app.name
}

resource "aws_iam_role_policy" "ec2_app" {
    role = aws_iam_role.ec2_app.name
    name = "policy-${var.project_name}"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["s3:Get*", "s3:List*"]
            Resource = ["arn:aws:s3:::dcorrea-artifacts/*"]
        }]
    })
}

resource "aws_iam_role" "code_app" {
    name                = "code-deploy-${var.project_name}"
    assume_role_policy  = data.aws_iam_policy_document.app.json
}

resource "aws_iam_role_policy_attachment" "code_app" {
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
    role        = aws_iam_role.code_app.name
}
