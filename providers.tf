terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
  }
}

provider "aws" {
    region = var.region
    access_key = var.accesskey
    secret_key = var.secretkey
}

resource "aws_iam_role" "lamda_role" {
  name = "lamda_role"
 assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"
#   role = aws_iam_role.lamda_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
},
    
  )
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lamda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}