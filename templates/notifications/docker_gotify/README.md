# Gotify

[Gotify](https://gotify.net) is a small, simple server for sending and receiving messages.

## Setup

- Copy the [example `.env` file](./.example.env) to `.env` and edit it.
  - At minimum, set a different admin password.
  - Most of the environment variables are optional, meaning the container will run with the defaults.
  - **The default settings are not sufficient for a "production" deployment**
- Run `docker compose up -d`
- Browse to `http://ip-or-fqdn:$PORT`
  - Use the `GOTIFY_PORT` for `$PORT` (default is :80. If you don't change the default, you can omit `:$PORT`)
- Create an `App` for sending requests by cURL.
  - You can also create additional users, or OAuth clients for applications.

## Making Requests

You can send messages using HTTP requests with cURL, or use the [Gotify CLI](https://github.com/gotify/cli).

Gotify also supports ["message extras"](https://gotify.net/docs/msgextras), which are used to carry extra information, change how clients behave, etc.

- Simple "hello world" request:

  ```shell
  curl "https://push.example.de/message?token=<apptoken>" \
    -F "title=Greetings" \
    -F "message=Hello, world!" \
    -F "priority=5"
  ```

- Bash with markdown:

  ```shell
  #!/usr/bin/env bash
  TITLE="My Title"
  MESSAGE="Hello: ![](https://gotify.net/img/logo.png)"
  PRIORITY=5
  URL="http://localhost:8008/message?token=<apptoken>"

  curl -s -S --data '{"message": "'"${MESSAGE}"'", "title": "'"${TITLE}"'", "priority":'"${PRIORITY}"', "extras": {"client::display": {"contentType": "text/markdown"}}}' -H 'Content-Type: application/json' "$URL"
  ```

- Request with Python:

  ```python
  import niquests # pip install niquests

  res = niquests.post("http://localhost:8008/messages?token=<apptoken>"", json={
    "message": "Well hello there.",
    "priority": 2,
    "title": "This is my title"
  })
  ```

- Request with Go:

  ```go
  package main

  import (
    "net/http"
    "net/url"
  )

  func main() {
      http.PostForm("http://localhost:8008/message?token=<apptoken>",
          url.Values{"message": {"My Message"}, "title": {"My Title"}})
  }
  ```

- With wget:

  ```shell
  token="<apptoken>"
  subject="wget"
  message="Test push from wget"
  priority=5

  wget "http://localhost:8008/message?token=$token" \
    --post-data "title=$subject&message=$message&priority=$priority" \
    -O /dev/null
  ```

## Create new app with curl

In Gotify, an application is a notification source. Each application gets its own token. You can create new apps with cURL:

```shel
curl -u admin:your-password \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"name": "Server Alerts", "description": "Critical server notifications"}' \
  http://localhost:8070/application
```
