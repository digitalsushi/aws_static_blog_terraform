# These are input variables to a terraform plan.
# This plan configures an S3 backed static content website
# on AWS, with a CloudFront CDN with a TLS certificate
# that provides HTTPS.
#
# Any variable without a default will be asked for at runtime.

variable "domain_name" {
  default = "example.com"
}

# This is your website's FQDN. This is not
# compatible with a 'naked domain', so you must provide a host.
variable "site_name" {
  default = "www.example.com"
}

variable "aws_region" {
	default = "us-east-1"
}

# This configures some basic terraform aws configuration using earlier values.
provider "aws" {
  region = var.aws_region
}

# This variable is a little tricky - a shell script included in this project
# will go ahead and generate a TLS signing request on your behalf, using the 
# aws-cli command. This ends up in your email and you have to verify it as
# the domain owner, before the Certificate Manager in the AWS console will list
# the domain as verified. Inside the out.txt file is the ARN of this new certificate,
# and you need to paste it back in here.
variable "certificate_arn" {
  default = "__UNKNOWN_WEBSITE_CERTIFICATE__"
}
