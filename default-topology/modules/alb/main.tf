#-------------
#    ALB
#-------------

module "alb_sg" {
  source      = "github.com/tieto-cem/terraform-aws-sg?ref=v0.1.0"
  name        = "${var.alb_name}-sg"
  vpc_id      = "${var.vpc_id}"
  allow_cidrs = "${var.allow_cidrs}"
}


module "alb" {
  source                         = "github.com/tieto-cem/terraform-aws-alb?ref=v0.1.2"
  name                           = "${var.alb_name}-alb"
  lb_internal                    = "${var.internal}"
  lb_subnet_ids                  = "${var.subnet_ids}"
  lb_security_group_ids          = ["${module.alb_sg.id}"]
  tg_vpc_id                      = "${var.vpc_id}"
  http_listener_enabled          = "${var.http_enabled}"
  https_listener_enabled         = "${var.https_enabled}"
  https_listener_certificate_arn = "${var.https_enabled ? join("", aws_iam_server_certificate.iam_certificate.*.arn) : ""}"
}


#-------------------
#  TLS Certificate
#-------------------

# Self-signed certificate

resource "tls_private_key" "private_key" {
  count     = "${var.https_enabled ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "tls_certificate" {
  count                 = "${var.https_enabled ? 1 : 0}"
  key_algorithm         = "${tls_private_key.private_key.algorithm}"
  private_key_pem       = "${tls_private_key.private_key.private_key_pem}"

  subject {
    common_name  = "myapp.org"
    organization = "My Org"
  }

  validity_period_hours = "${24 * 365 * 2}"

  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "aws_iam_server_certificate" "iam_certificate" {
  count            = "${var.https_enabled ? 1 : 0}"
  name             = "${var.alb_name}-certificate"
  certificate_body = "${tls_self_signed_cert.tls_certificate.cert_pem}"
  private_key      = "${tls_private_key.private_key.private_key_pem}"
}
