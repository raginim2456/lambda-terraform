provider "aws" {
  region = "us-east-1"  # Change if needed
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_policy"
  description = "Allow Lambda to access S3 and logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::ragini-devops-bucket/*"
      },
      {
        Effect = "Allow"
        Action = "logs:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_lambda_function" "S3EventLogger" {
  function_name = "S3EventLogger"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "S3EventLogger.zip"  # You must manually upload this ZIP file into the same folder
  source_code_hash = filebase64sha256("S3EventLogger.zip")
}

resource "aws_lambda_permission" "allow_s3_to_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  function_name = aws_lambda_function.S3EventLogger.function_name
  source_arn    = "arn:aws:s3:::ragini-devops-bucket"
}

resource "aws_s3_bucket_notification" "s3_event_trigger" {
  bucket = "ragini-devops-bucket"

  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = aws_lambda_function.S3EventLogger.arn
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke]
}
