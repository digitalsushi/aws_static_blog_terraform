# These are input variables to a terraform plan.
# This plan configures an S3 backed static content website
# on AWS, with a CloudFront CDN with a TLS certificate
# that provides HTTPS.
#
# Any variable without a default will be asked for at runtime.

variable "domain_name" {
  default = "example.com"
}

# This is your website's FQDN. This is probably not
# compatible with a 'naked domain', so it is recommended
# that you definitely use a hostname in addition to your domain name.
variable "site_name" {
  default = "blog.example.com"
}

variable "aws_region" {
	default = "us-east-1"
}

# These next two are your public and private key.
# You should never check your private key in and you're
# probably not popular with security minded folks if you
# commit your public key.
variable "aws_access_key" {
  description = "your public aws key"
  default = "ZZZ"
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
