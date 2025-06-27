data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/cloudfront_disable.py"
  output_path = "${path.module}/lambda/cloudfront_disable.zip"
}

resource "aws_lambda_function" "disable_cf" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "DisableCloudFrontOnBudget"
  role             = aws_iam_role.lambda_cf_role.arn
  handler          = "cloudfront_disable.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DISTRIBUTION_ID = resource.aws_cloudfront_distribution.apt_cf.id
      SNS_TOPIC_ARN   = aws_sns_topic.cf_alerts_email.arn
    }
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.disable_cf.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.budget_alerts.arn
}

resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.disable_cf.arn
}



