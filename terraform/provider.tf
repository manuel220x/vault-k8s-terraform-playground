provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-vault"
}

provider "tls" {
    
}

provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables:
  #    - VAULT_ADDR
  #    - VAULT_TOKEN
  #    - VAULT_CACERT
  #    - VAULT_CAPATH
  #    - etc.
}