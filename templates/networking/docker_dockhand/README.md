# Dockhand

[Dockhand](https://github.com/Finsys/dockhand) is a Docker management UI.

## Authentik OIDC Setup

If you use Authentik for your IdP, you can set up OAuth sign-in using the instructions below.

- In Dockhand:
  - Go to Settings > Authentication > SSO/OIDC.
  - Click "Add provider."
  - Enter "Authentik" for the name, and your Authentik URL in "Issuer URL," with the following appended: `/application/o/dockhand`
    - Example: `https://auth.example.com/application/o/dockhand`.
  - Copy the value in "Redirect URI."

- In Authentik:
  - In the admin dashboard, go to Applications > Applications.
  - Click "New Application."
  - Give it a name, i.e. "Dockhand," then click next.
  - For the provider, choose "OAuth2/OpenID Provider" and click next.
  - Use the default authorization flow.
  - Scroll past the client ID and secret to "Redirect URIs/Origins (RegEx)" and paste the value you copied from Dockhand.
  - Scroll back up and copy the client ID and secret.
    - You should save these in a password manager.
  - Click next and configure bindings, or leave them empty and click next and "Create Application."

- In Dockhand:
  - Paste the client ID and secret you copied from Authentik into the "Client ID" and "Client Secret" boxes, respectively.
  - Click "Add provider."

Refresh the page and you should see an "Authentik" button on the login page now.
