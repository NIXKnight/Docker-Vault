# Generate root CA
resource "vault_pki_secret_backend_root_cert" "nixknight_ca" {
  depends_on = [ vault_mount.nixknight_ca_authority ]

  issuer_name = "NIXKNIGHT-Root-Issuer"

  common_name  = "NIXKNIGHT Root CA"
  organization = "NIXKNIGHT"
  country      = "PK"
  locality     = "Lahore"
  province     = "Punjab"

  backend  = vault_mount.nixknight_ca_authority.path
  type     = "internal"
  ttl      = "315360000" # 10 years
  key_type = "rsa"
  key_bits = 4096
}

# Configure the CA's URLs
resource "vault_pki_secret_backend_config_urls" "nixknight_ca" {
  backend                 = vault_mount.nixknight_ca_authority.path
  issuing_certificates    = [ "http://${var.vault_address}/v1/${vault_mount.nixknight_ca_authority.path}/ca" ]
  crl_distribution_points = [ "http://${var.vault_address}/v1/${vault_mount.nixknight_ca_authority.path}/crl" ]
}
