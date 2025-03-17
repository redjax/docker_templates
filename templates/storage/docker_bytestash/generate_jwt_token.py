import base64
import json
import hmac
import hashlib


def base64url_encode(data: bytes) -> str:
    """Encodes data in Base64 URL format without padding."""
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def base64url_decode(data: str) -> bytes:
    """Decodes Base64 URL data, adding padding if necessary."""
    padding = "=" * (-len(data) % 4)  # Ensure proper padding
    return base64.urlsafe_b64decode(data + padding)


def generate_jwt(payload: dict, secret: str, algorithm="HS256") -> str:
    """Generates a JWT token using only Python stdlib."""
    if algorithm != "HS256":
        raise ValueError("Only HS256 is supported with stdlib")

    header = {"alg": "HS256", "typ": "JWT"}

    # Base64URL encode header and payload
    encoded_header = base64url_encode(
        json.dumps(header, separators=(",", ":")).encode()
    )
    encoded_payload = base64url_encode(
        json.dumps(payload, separators=(",", ":")).encode()
    )

    # Create the signature
    signature_input = f"{encoded_header}.{encoded_payload}".encode()
    signature = hmac.new(secret.encode(), signature_input, hashlib.sha256).digest()
    encoded_signature = base64url_encode(signature)

    # Create JWT
    return f"{encoded_header}.{encoded_payload}.{encoded_signature}"


def verify_jwt(token: str, secret: str, algorithm="HS256") -> dict:
    """Verifies a JWT token and returns the payload if valid."""
    if algorithm != "HS256":
        raise ValueError("Only HS256 is supported with stdlib")

    try:
        # Split the JWT into its parts
        encoded_header, encoded_payload, encoded_signature = token.split(".")

        # Decode and parse header
        header = json.loads(base64url_decode(encoded_header).decode())
        if header.get("alg") != "HS256":
            raise ValueError("Unsupported algorithm")

        # Recreate the signature
        signature_input = f"{encoded_header}.{encoded_payload}".encode()
        expected_signature = hmac.new(
            secret.encode(), signature_input, hashlib.sha256
        ).digest()
        expected_signature_encoded = base64url_encode(expected_signature)

        # Compare signatures
        if not hmac.compare_digest(encoded_signature, expected_signature_encoded):
            raise ValueError("Invalid signature")

        # Decode and return payload
        payload = json.loads(base64url_decode(encoded_payload).decode())
        return payload

    except (ValueError, json.JSONDecodeError, base64.binascii.Error) as e:
        raise ValueError(f"JWT verification failed: {e}")


# Example usage
payload = {"sub": "1234567890", "name": "John Doe", "iat": 1710000000}
secret = "your-256-bit-secret"

jwt_token = generate_jwt(payload, secret)
print(f"Token: {jwt_token}")

try:
    decoded_payload = verify_jwt(jwt_token, secret)
    print("JWT is valid! Payload:", decoded_payload)
except ValueError as e:
    print("JWT verification failed:", e)
