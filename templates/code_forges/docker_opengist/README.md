# OpenGist

[OpenGist](https://opengist.io) is a self-hosted pastebin alternative to Github Gist/Gitlab Snippets.

## Quickstart

Run this if you want to just test Opengist before committing to running it in a permanent way, or if you are happy with the defaults:

```shell
docker run --name opengist -p 6157:6157 -v "$HOME/.opengist:/opengist" ghcr.io/thomiceli/opengist:1
```
