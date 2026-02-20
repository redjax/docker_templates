## App1 can only access its own secrets
path "secret/app1/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}