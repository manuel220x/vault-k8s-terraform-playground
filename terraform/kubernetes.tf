resource "kubernetes_secret" "tls-ca" {
  metadata {
    name = "tls-ca"
    namespace = var.namespace
  }

  data = {
    "tls.key" = tls_private_key.tf-ca-key.private_key_pem #"${file("../tls/ca-key.pem")}"
    "tls.crt" = tls_self_signed_cert.tf-ca.cert_pem #"${file("../tls/ca.pem")}"
  }
  

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "tls-server" {
  metadata {
    name = "tls-server"
    namespace = var.namespace
  }

  data = {
    "tls.key" = tls_private_key.tf-vault-key.private_key_pem #"${file("../tls/vault-key.pem")}"
    "tls.crt" = tls_locally_signed_cert.tf-vault-cert.cert_pem #"${file("../tls/vault.pem")}"
  }
  
  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "tls-transit-server" {
  metadata {
    name = "tls-transit-server"
    namespace = var.namespace
  }

  data = {
    "tls.key" = tls_private_key.tf-vault-transit-key.private_key_pem #"${file("../tls/vault-key.pem")}"
    "tls.crt" = tls_locally_signed_cert.tf-vault-transit-cert.cert_pem #"${file("../tls/vault.pem")}"
  }
  
  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "transit" {
  metadata {
    name = "transit"
    namespace = var.namespace
  }

  data = {
    "token" = vault_token.transit.client_token #"${file("../tls/vault-key.pem")}"
  }
  
  type = "Opaque"
}