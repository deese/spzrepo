resource "aws_sns_topic" "budget_alerts" {
  name = var.sns_topic_budget_alarm
}

resource "aws_sns_topic" "cf_alerts_email" {
  name = "cloudfront-disabled-alert"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.cf_alerts_email.arn
  protocol  = "email"
  endpoint  = var.notification_email
}


