disable_mlock = true
ui = true

listener "tcp" {
  tls_disable = 1
  address = "[::]:8200"
  cluster_address = "[::]:8201"
}

storage "postgresql" {
  connection_url = "postgres://master:password@postgresql:5432/vault?sslmode=disable"
}
