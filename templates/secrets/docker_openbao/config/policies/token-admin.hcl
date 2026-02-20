## Can create, lookup, and revoke tokens
path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete", "sudo"]
}