# Make a certificate.
resource "aws_acm_certificate" "default" {
  domain_name       = "vault.aws.adfinis.cloud"
  validation_method = "DNS"
  tags = {
    owner = "robertdebock"
  }
}

# Lookup DNS zone.
data "aws_route53_zone" "default" {
  name = "aws.adfinis.cloud"
}

# Add validation details to the DNS zone.
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.default.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.default.zone_id
}

# Call the module.
module "vault" {
  source                      = "robertdebock/vault/aws"
  version                     = "10.1.6"
  vault_aws_certificate_arn   = aws_acm_certificate.default.arn
  vault_enable_cloudwatch     = true
  vault_asg_instance_lifetime = 86400
  vault_name                  = "rdb"
  vault_keyfile_path          = "id_rsa.pub"
  vault_size                  = "development"
  vault_tags = {
    owner = "Robert de Bock"
  }
}

# Add a loadbalancer record to DNS zone.
resource "aws_route53_record" "default" {
  name    = "vault"
  type    = "CNAME"
  ttl     = 300
  records = [module.vault.aws_lb_dns_name]
  zone_id = data.aws_route53_zone.default.id
}
