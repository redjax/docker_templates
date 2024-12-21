# Wazuh

Dockerized Wazuh XDR/SIEM server

## Description

[wazuh](https://wazuh.com) is a free, open-source, self-hosted XDR & SIEM platform.

The [installation for Wazuh in Docker](https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html) is different from other templates in this repository. Their setup instructions have you clone a git repository, and do everything from the cloned path.

This template has a script in [./scripts](./scripts/) that handles cloning the repository and running the setup steps. The `wazuh-docker` repository that is cloned by this script is ignored in the [.gitignore](./.gitignore); you will need to clone this again each time.

### Updating

**TODO**
