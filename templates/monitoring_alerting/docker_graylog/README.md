# Docker Graylog + OpenSearch

- [Dockerhub: graylog/graylog](https://hub.docker.com/r/graylog/graylog)
- [Github: graylog2/graylog](https://github.com/Graylog2/graylog-docker)
- [Dockerhub: mongodb/mongodb-community-server](https://hub.docker.com/r/mongodb/mongodb-community-server/tags)

## Ports

| Port | Purpose | Required | TCP/UDP |
| ---- | ------- | -------- | ------- |
| `9000` | webUI | True | TCP |
| `5140` | Syslog | True | Both |
| `27017` | MongoDB | True | TCP |
| `9200` | OpenSearch REST API | True | TCP |
| `9600` | Performance Analyser | True | TCP |
| `5044` | Beats | False | TCP |
| `5555` | Raw TCP | False | Both |
| `12201` | GELF TCP/UDP | False | Both |
| `13301` | Forwarder data | False | Both |
| `13302` | Forwarder config | False | Both |
| `10000` | Optional custom TCP/UDP port | False | Both |

## Notes

- Use named volumes (the default) for the `graylog` container. You'll get permission errors with a host volume mount.
