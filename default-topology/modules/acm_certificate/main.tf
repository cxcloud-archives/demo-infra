resource "aws_acm_certificate" "certificate" {
  domain_name       = "${var.certificate_domain_name}"
  validation_method = "DNS"
}


provider "aws" {
  alias  = "route53"
  region = "eu-west-1"
  assume_role {
    role_arn = "${var.route53_configuration_role}"
  }
}

data "aws_route53_zone" "zone" {
  provider     = "aws.route53"
  name         = "${var.zone_domain_name}"
  private_zone = false
}

resource "aws_route53_record" "dns_validation" {
  provider = "aws.route53"
  name     = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name}"
  type     = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type}"
  zone_id  = "${data.aws_route53_zone.zone.id}"
  records  = ["${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
  ttl      = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.dns_validation.fqdn}"]
}


