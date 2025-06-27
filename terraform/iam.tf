resource "aws_iam_role" "lambda_cf_role" {
  name = "lambda_disable_cf_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_cf_policy" {
  name = "lambda_disable_cf_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = "${aws_sns_topic.cf_alerts_email.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cf_attach" {
  role       = aws_iam_role.lambda_cf_role.name
  policy_arn = aws_iam_policy.lambda_cf_policy.arn
}

