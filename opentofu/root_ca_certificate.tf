# Enable the PKI secrets engine
resource "vault_mount" "nixknight_ca_authority" {
  path                      = "nixknight_ca_authority"
  type                      = "pki"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 315360000 # 10 years
}

# Generate root CA
resource "vault_pki_secret_backend_root_cert" "nixknight_ca" {
  depends_on = [ vault_mount.nixknight_ca_authority ]

  issuer_name = "NIXKNIGHT-Root-Issuer"

  common_name  = "nixknight.net"
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

# Generate intermediate CA using the root CA
resource "vault_pki_secret_backend_issuer" "nixknight_ca_intermediate" {
   backend                        = vault_mount.nixknight_ca_authority.path
   issuer_ref                     = vault_pki_secret_backend_root_cert.nixknight_ca.issuer_id
   issuer_name                    = vault_pki_secret_backend_root_cert.nixknight_ca.issuer_name
   revocation_signature_algorithm = "SHA256WithRSA"
}

# Set role with proper constraints
resource "vault_pki_secret_backend_role" "nixknight_ca_intermediate" {
  name    = "NIXKNIGHT-Intermediate-Root-CA-Role"

  backend         = vault_mount.nixknight_ca_authority.path
  issuer_ref       = vault_pki_secret_backend_issuer.nixknight_ca_intermediate.issuer_ref

  allow_any_name = true
  enforce_hostnames = false
  allow_localhost = false
  allow_wildcard_certificates = false
  key_type = "rsa"
  key_bits = 4096

  key_usage = [
    "digitalSignature",
    "nonRepudiation",
    "keyEncipherment",
    "dataEncipherment"
  ]

  allowed_domains  = ["vms.nixknight.net"]
  allow_subdomains = true

  max_ttl = "315360000"
  require_cn = false
}


# Create certificate for VM
resource "vault_pki_secret_backend_cert" "vm1" {
  issuer_ref  = vault_pki_secret_backend_issuer.nixknight_ca_intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.nixknight_ca_intermediate.backend
  name        = vault_pki_secret_backend_role.nixknight_ca_intermediate.name
  common_name = "vm1.vms.nixknight.net"
  ttl         = 3600
  revoke     = true
}
