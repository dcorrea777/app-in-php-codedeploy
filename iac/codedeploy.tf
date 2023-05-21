resource "aws_codedeploy_app" "app" {
    compute_platform = "Server"
    name             = var.project_name
}

resource "aws_codedeploy_deployment_group" "app" {
    app_name                = aws_codedeploy_app.app.name
    deployment_group_name   = "${var.project_name}-group"
    service_role_arn        = aws_iam_role.code_app.arn

    ec2_tag_set {
        ec2_tag_filter {
            key   = "App"
            type  = "KEY_AND_VALUE"
            value = var.project_name
        }
    }

    trigger_configuration {
        trigger_events     = ["DeploymentFailure"]
        trigger_name       = "example-trigger"
        trigger_target_arn = aws_sns_topic.app.arn
    }

    auto_rollback_configuration {
        enabled = true
        events  = ["DEPLOYMENT_FAILURE"]
    }

    alarm_configuration {
        alarms  = ["my-alarm-name"]
        enabled = true
    }
}
