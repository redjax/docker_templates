## App1 can only access its own secrets
path "secret/app1/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

## Allow access to the /secret/shared/ path
path "secret/shared/*" {
  capabilities = ["read"]
}