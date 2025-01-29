# Step 2: S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "Firstbucket" {
  bucket = "my-static-website-bucket-team5"
}

# Step 3: Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.Firstbucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Step 4: S3 Public Access Block Configuration
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.Firstbucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Step 5: S3 Bucket ACL
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.Firstbucket.id
  acl    = "public-read"
}

# Step 6: Template file to replace API URL dynamically in index.html
data "template_file" "webapp_index" {
  template = file("${path.module}/webapp/index.html")  # Reference to the index.html file

  vars = {
    api_url = "https://${aws_apprunner_service.api_service.service_url}"  # Prepend https:// to the API URL
  }
}

# Step 7: S3 Object for Static Website (index.html)
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.Firstbucket.id
  key    = "index.html"
  content = data.template_file.webapp_index.rendered  # Use the rendered template
  content_type = "text/html"
  acl    = "public-read"
}

# Step 8: S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.Firstbucket.id

  index_document {
    suffix = "index.html"
  }

  depends_on = [aws_s3_bucket_acl.example]
}

# Step 9: CORS Configuration for S3 Bucket
resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.Firstbucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]  # Update this with your specific domain for production
    expose_headers   = ["Content-Type"]
  }
}

# Step 10: IAM Role for App Runner to Access ECR
resource "aws_iam_role" "app_runner_ecr_role" {
  name = "app-runner-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_runner_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.app_runner_ecr_role.name
}

# Step 11: Create ECR Repository
resource "aws_ecr_repository" "api_repo" {
  name = "my-api-repo"
}

# Step 12: Automate Docker Image Build, Tag, and Push 
resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
   
    interpreter = ["powershell", "-Command"]

    command = <<EOT
    aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.api_repo.repository_url} ;
    docker build -t my-api-repo:latest . ;
    docker tag my-api-repo:latest ${aws_ecr_repository.api_repo.repository_url}:latest ;
    docker push ${aws_ecr_repository.api_repo.repository_url}:latest
    EOT
  }

  # Ensure the ECR repository is created before running the provisioner
  depends_on = [aws_ecr_repository.api_repo]
}


# Step 13: Deploy Custom Docker API to AWS App Runner
resource "aws_apprunner_service" "api_service" {
  service_name = "my-api-service"

  source_configuration {
    image_repository {
      image_identifier = "${aws_ecr_repository.api_repo.repository_url}:latest"  # Ensure to use the latest tag
      image_configuration {
        port = "8080"
      }
      image_repository_type = "ECR"
    }

    # Specify the IAM Role to allow App Runner to access ECR
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_ecr_role.arn
    }
  }

  depends_on = [null_resource.docker_build_push]
}
