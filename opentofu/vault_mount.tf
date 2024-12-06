# Enable the PKI secrets engine
resource "vault_mount" "nixknight_ca_authority" {
  path                      = "nixknight_ca_authority"
  type                      = "pki"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 315360000 # 10 years
}
