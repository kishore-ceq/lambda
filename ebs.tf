
locals{
    ebs_source_file = "ebs.py"
    ebs_output_file = "outputs/ebs.zip"
}

data "archive_file" "new"{
    type = "zip"
    source_file = "${local.ebs_source_file}"
    output_path = "${local.ebs_output_file}"
}
resource "aws_lambda_function" "ebs_function" {   
  filename      = local.ebs_output_file
  function_name = "ebs_function"
  role          = aws_iam_role.lamda_role.arn
  handler       = "index.test"

  
  #source_code_hash = filebase64sha256("ebs.zip")

  runtime = "python3.7"

  environment {
    variables = {
        CLIENT_ID = var.clientid
        CLIENT_SECRET = var.clientsecret
        PASSWORD = var.password
        USERNAME = var.username
    }
  }
    depends_on = [
    aws_iam_role_policy_attachment.lambda_attach,
  ]
}


resource "aws_cloudwatch_event_rule" "ebsrule" {
  name                = "ebsvolume"
  schedule_expression = "cron(0/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "ebsvolume" {
  target_id = "ebsvolume"
  arn       = aws_lambda_function.ebs_function.arn
  rule      = aws_cloudwatch_event_rule.ebsrule.name
 

}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_test_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.ebs_function.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.ebsrule.arn
}
# resource "aws_cloudwatch_log_group" "ebs_loggroup" {
#   name = "ebs_loggroup"
# }