provider "aws" {
  region = "ap-southeast-1"
}

#Create DynamoDB Table
resource "aws_dynamodb_table" "Quotes" {
  name           = "Quotes"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }

}

# Insert items into DynamoDB Table using CreateTable.py
resource "null_resource" "setup_db" {
  depends_on = [aws_dynamodb_table.Quotes] #wait for the db to be ready
  provisioner "local-exec" {
    command = "python CreateTable.py"
  }
}

# Create IAM Role for Lambda Function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach IAM Policies to the IAM Role
resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/CloudWatchFullAccess", 
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonSNSRole",
    "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
  ])

  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = each.value
}

# Create Lambda Function
resource "aws_lambda_function" "quotes_lambda" {
  filename      = "lambda.zip"
  function_name = "quotes_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda.py"))}"
  source_code_hash = filebase64sha256("lambda.zip")

  runtime = "python3.8"
}

# Create CloudWatch Rule
resource "aws_cloudwatch_event_rule" "every_day_at_8am" {
    name = "every_day_at_8am"
    description = "Invoke daily at 8am"
    schedule_expression = "cron(0 0 * * ? *)"
}

# Attach CloudWatch Rule to Lambda Function(target)
resource "aws_cloudwatch_event_target" "push_quotes_daily_8am" {
    rule = "${aws_cloudwatch_event_rule.every_day_at_8am.name}"
    target_id = "quotes_lambda"
    arn = "${aws_lambda_function.quotes_lambda.arn}"
}

# Give Cloudwatch Rule permission to invoke Lambda Function
resource "aws_lambda_permission" "allow_cloudwatch_to_call_quotes_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.quotes_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_day_at_8am.arn}"
}