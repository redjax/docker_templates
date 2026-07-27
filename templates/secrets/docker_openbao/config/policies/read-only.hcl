## Can read secrets but not create or modify them
path "secret/*" {
  capabilities = ["read", "list"]
}