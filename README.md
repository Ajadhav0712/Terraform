# Terraform Assignment

In this assignment, you will use [Terraform](https://www.notion.so/Terraform-aa7a71ef03ff4ddaa74877d9599eed01?pvs=21) to deploy a static website and an API container to a cloud provider.

## 1. Register free Cloud Provider Account

Register an AWS Cloud account. Will will use the free tier offerings of either provider.

[Free Cloud Computing Services - AWS Free Tier](https://aws.amazon.com/free)

## 2. Setup Terraform and Provider

### 1. Install Terraform

Install Terraform on your local system. 

[Install | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/install)

### 2. Install Provider

Install AWS provider in `providers.tf`. Before installing, it makes sense to also install the `awscli` cli. Pull in the provider code with `terraform init`.

[Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### 3. Setup Credentials

Follow the setup instructions for either provider and setup your credentials to connect.

## 3. Host a Static Website using an Object Storage Service

Create a basic `index.html` containing the words `“Hello Cloud”` in a `webapp` folder. Then use  S3 resources to deploy the file as a public website.

[Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

Make sure, you can access the website using a public URL from your browser.

## 4. Deploy an API Container

Find a public docker image, which starts a webserver and returns a simple JSON response. Use AWS App Runner with the respective terraform resources to host a public API service with the image.

[Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_service)

Make sure, you can access the website using a public URL from your browser.

## 5. Call the API from the Website

Adapt your website. Add a button, which calls the API using the JavaScript `fetch` API and display the result on the page.

[Fetch API - Web APIs | MDN](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)

Make sure you don’t hard code the API URL in the website. Can you find a way to make Terraform automatically put the URL in the website files, e.g. using templatefiles?

[templatefile - Functions - Configuration Language | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/functions/templatefile)

## 6. Deploy Custom Docker API Image

For full points, create a simple, custom API image using any programming language of your choice, deploy it to AWS’ Elastic Container Registry. 

Then, adapt your API to use this new image and deploy.

[What is Amazon Elastic Container Registry? - Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
