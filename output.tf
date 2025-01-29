# Outputs
# Output the website URL
output "website_url" {
  value = aws_s3_bucket.Firstbucket.website_endpoint
}

# Output the App Runner API URL
output "api_url" {
  value = aws_apprunner_service.api_service.service_url
}
