data "aws_iam_policy_document" "app" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["codedeploy.amazonaws.com"]
        }
    }
}
