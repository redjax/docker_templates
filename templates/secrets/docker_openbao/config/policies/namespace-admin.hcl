## Can manage secrets only within a specific namespace
path "secret/homelab.dev/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete"]
}