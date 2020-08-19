# This is a terraform plan for creating a static S3 website with TLS.

# Please see the README for a high level explanation of what this is.

# Newbie note: a 'resource' in terraform creates a thing, 'data' learns a thing.
# Newbie note: Until things get more complicated, a zone and domain are the same thing.

# DNS STUFF.
#
# This first resource is disabled (by commenting it out). It creates a new 
# DNS zone. Since you probably don't want to create a new zone,
# but rather use an existing one, we have left the next resource as active, instead.
#
#resource "aws_route53_zone" "site_zone" {
#  name     = var.domain_name
#  force_destroy = true
#}

# This will automatically learn the zone ID of your aws hosted domain, so
# that terraform can add records to it.
data "aws_route53_zone" "site_zone" {
  name         = var.domain_name
  private_zone = false
}

# Creates a new DNS cname of static.example.com that points to the canonical
# aws url of your static s3 bucket. This is a nice convenience URL for you to 
# admin your site, and is not required.
resource "aws_route53_record" "site_cname_static" {
  zone_id  = data.aws_route53_zone.site_zone.zone_id
  name     = "static.${var.domain_name}"
  type = "CNAME"
  ttl = "30"
  records = [
    "${aws_s3_bucket.site_bucket.bucket_domain_name}"
  ]
}

# Creates a new DNS CNAME of your new website host. This will be your real website url
# of https://www.example.com/ or whatever host you chose in vars.tf (blog.example.com, etc)
resource "aws_route53_record" "site_cname" {
  zone_id  = data.aws_route53_zone.site_zone.zone_id
  name = var.site_name
  type = "CNAME"
  ttl = "30"
  records = [
    "${aws_cloudfront_distribution.site_distribution.domain_name}"
  ]
}

# Creates a new S3 bucket with the name of your website. It will be accessible 
# over a random amazonaws.com URL. Later, the CloudFront configuration will
# configure www.example.com to be the front-end URL that visitors access.
resource "aws_s3_bucket" "site_bucket" {
  bucket = var.site_name
  acl = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Creates a new Cloudfront Content Delivery Network service. 
#
# Our Certificate is also referenced here, which you handled earlier before
# terraform was run.

resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = aws_s3_bucket.site_bucket.bucket_domain_name
    origin_id = "${var.site_name}-origin"
  }
  enabled = true
  aliases = ["${var.site_name}"]
  price_class = "PriceClass_100"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.site_name}-origin"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 1000
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn   = var.certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}
