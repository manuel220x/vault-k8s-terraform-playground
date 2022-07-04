resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

# RSA key of size 2048 bits
resource "tls_private_key" "tf-ca-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_private_key" "tf-vault-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_private_key" "tf-vault-transit-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "tf-ca" {
  private_key_pem = tls_private_key.tf-ca-key.private_key_pem

  is_ca_certificate = true

  subject {
    country  = "MX"
    locality = "Mexico"
    organization = "TechMahindra"
    organizational_unit = "MX"
    province = "Mexico"
  }

  validity_period_hours = 175200

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_cert_request" "tf-vault-csr" {
  private_key_pem = tls_private_key.tf-vault-key.private_key_pem

  subject {
    country  = "MX"
    locality = "Mexico"
    organization = "TechMahindra"
    organizational_unit = "MX"
    province = "Mexico"
  }
  ip_addresses = [ "127.0.0.1" ]
  dns_names = [
    "cluster.local","vault","vault.vault.svc.cluster.local","vault.vault.svc","localhost",
    "vault-0.vault-internal","vault-1.vault-internal","vault-2.vault-internal","vault-3.vault-internal"
    ]
}

resource "tls_cert_request" "tf-vault-transit-csr" {
  private_key_pem = tls_private_key.tf-vault-transit-key.private_key_pem

  subject {
    country  = "MX"
    locality = "Mexico"
    organization = "TechMahindra"
    organizational_unit = "MX"
    province = "Mexico"
  }
  ip_addresses = [ "127.0.0.1" ]
  dns_names = [
    "cluster.local","vault","vault.vault.svc.cluster.local","vault.vault.svc","localhost",
    "vault-transit-0.vault-transit"
    ]
}

resource "tls_locally_signed_cert" "tf-vault-cert" {
  cert_request_pem   = tls_cert_request.tf-vault-csr.cert_request_pem
  ca_private_key_pem = tls_private_key.tf-ca-key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.tf-ca.cert_pem

  validity_period_hours = 175200

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_locally_signed_cert" "tf-vault-transit-cert" {
  cert_request_pem   = tls_cert_request.tf-vault-transit-csr.cert_request_pem
  ca_private_key_pem = tls_private_key.tf-ca-key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.tf-ca.cert_pem

  validity_period_hours = 175200

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}