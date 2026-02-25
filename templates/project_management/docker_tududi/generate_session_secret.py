import secrets

secret = secrets.token_hex(64)
print(f"TUDUDI_SESSION_SECRET={secret}")
