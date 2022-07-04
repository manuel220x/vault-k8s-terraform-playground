output "ca-cert" {
  description = "Cert that must be saved on a file and then set the environment variable: VAULT_CACERT which value should be the path of this file"
  value = tls_self_signed_cert.tf-ca.cert_pem
}

output "token" {
  sensitive = false
  value = vault_token.transit.id
}