data "vault_policy_document" "policy_data_autounseal" {
    rule {
        path         = "transit/encrypt/autounseal"
        capabilities = ["update"]
        description  = "Encrypt autounseal rule"
    }
    rule {
        path         = "transit/decrypt/autounseal"
        capabilities = ["update"]
        description  = "Decrypt autounseal rule"
    }
}

resource "vault_policy" "autounseal" {
  name       = "autounseal"
  policy     = data.vault_policy_document.policy_data_autounseal.hcl
}

resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "Mount transit engine"

  options = {
    convergent_encryption = false
  }
}

resource "vault_transit_secret_backend_key" "autounseal" {
  backend = vault_mount.transit.path
  name    = "autounseal"
}

resource "vault_token" "transit" {

  policies = ["autounseal"]

  renewable = true
  ttl = "24h"

  renew_min_lease = 43200
  renew_increment = 86400
}