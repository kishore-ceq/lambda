locals{
    eip_source_file = "eip.py"
    eip_output_file = "outputs/eip.zip"
}

data "archive_file" "new1"{
    type = "zip"
    source_file = "${local.eip_source_file}"
    output_path = "${local.eip_output_file}"
}
resource "aws_lambda_function" "eip_function" {
  filename      = local.eip_output_file
  function_name = "eip_function"
  role          = aws_iam_role.lamda_role.arn
  handler       = "index.test"

  
  #source_code_hash = filebase64sha256("eip.zip")

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

resource "aws_cloudwatch_event_rule" "eiprule" {
  name                = "eipips"
  schedule_expression = "cron(0/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "eipips" {
  target_id = "eipips"
  arn = aws_lambda_function.eip_function.arn
  rule      = aws_cloudwatch_event_rule.eiprule.name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_test_lambda1" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name =aws_lambda_function.eip_function.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.eiprule.arn
}
# resource "aws_cloudwatch_log_group" "eip_loggroup" {
#   name = "eip_loggroup"
 
# }
