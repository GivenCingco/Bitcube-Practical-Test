#CodeDeploy application
resource "aws_codedeploy_app" "Bitcube_nextjs" {
  name            = "BitcubeNextjsApp"
  compute_platform = "Server"  
}


#CodeDeployment group
resource "aws_codedeploy_deployment_group" "bitcube_deployment_group1" {
  app_name              = aws_codedeploy_app.Bitcube_nextjs.name
  deployment_group_name = "BitcubeDeploymentGroup1"
  service_role_arn      = aws_iam_role.codedeploy_default_role.arn

  ec2_tag_filter {
      key   = "Environment"
      value = "BitcubeCodeDeploy"
      type = "KEY_AND_VALUE"
    }
 

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
