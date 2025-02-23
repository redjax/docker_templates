import secrets
import base64

secret = base64.b64encode(secrets.token_bytes(32)).decode()
salt = base64.b64encode(secrets.token_bytes(32)).decode()
vault_pwd = base64.b64encode(secrets.token_bytes(16)).decode()

print(f"Secret: {secret}")
print(f"Salt: {salt}")
print(f"Vault Password: {vault_pwd}")
