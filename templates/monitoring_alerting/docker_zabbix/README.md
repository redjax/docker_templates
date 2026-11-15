# Zabbix <!-- omit in toc -->

[Zabbix](https://github.com/zabbix/zabbix) is a real-time monitoring solution with a server/agent architecture.

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
- [Usage](#usage)
- [Zabbix Agent](#zabbix-agent)
  - [Install Zabbix agent](#install-zabbix-agent)
  - [Agent Auto-regsitration](#agent-auto-regsitration)
  - [Uninstall Zabbix agent](#uninstall-zabbix-agent)

## Setup

`...`

## Usage

Run `docker compose up -d`, then navigate to `http(s)://your-ip-or-hostname:8080`.

At the login screen, use the default Zabbix admin credentials:

```plaintext
Admin
zabbix
```

## Zabbix Agent

> [!NOTE]
> [Click here for official Zabbix agent installation/configuration docs](https://www.zabbix.com/documentation/current/en/manual/concepts/agent)

### Install Zabbix agent
 
The [`install-zabbix-agent.sh` script](./scripts/install-zabbix-agent.sh) can handle installation of the Zabbix agent across a range of Linux hosts. The script detects the platform, and accepts inputs to install & configure the Zabbix agent on a host. Run with `-h` or `--help` to see options.

Example installation, sets server IP to `192.168.1.7` and adds 2 metadata tags, `autoregister` and `os=linux`:

```shell
./scripts/install-zabbix-agent.sh -s 192.168.1.7 -m autoregister -m os=linux
```

### Agent Auto-regsitration

> [!NOTE]
> These steps are accurate as of 2025-12-10, and Zabbix v7.4.5

Before creating an autoregistration rule, you need to create a template. You can create a template by going to `Data collection > Templates` and clicking the `Create template` button in the top right

- If you don't want to setup a template for autoregistration, just create a 'dummy' template
  - Give it a name like `Autoregister Dummy Template`
  - Optionally set a `Visible name`
  - Pick/create a group, i.e. `Autoregister`
  - Save the template

In the Zabbix server UI, open `Alerts > Actions > Autoregistration actions` and follow the steps below to create an autoregistration rule.

- Click `Create action` in the top right
- Give the action a name like `Auto-register devices with 'autoregister' metadata tag`.
- Under `Conditions`, click the `Add` button
  - Choose `Host metadata` in the `Type` dropdown
  - Set the `Operator` to `contains`
  - Set the `Value` to `autoregister`
- Click the `Operations` tab
- Click the `Add` button under `Operations`
  - Set the `Operation` dropdown to `Add to host group`
  - In the search box, type a group name, i.e. `Linux servers`, or use the `Select` button to see a full list.
  - When finished, click the `Add` button
- Click the `Add` button to add another action
  - In the `Operation` dropdown, choose `Link template`
  - Type the name of a template, i.e. 

Now when you start the agent, it should automatically register itself with Zabbix.

### Uninstall Zabbix agent

> [!WARNING]
> This script is destructive. It not only uninstalls the Zabbix agent, it also deletes the configuration, logs, and systemd service file. The script will prompt for `y`/`n` before deleting anything.
>
> You can override this and force the uninstall/purge by passing `-f`/`--force`.

Run the [`uninstall-zabbix-agent.sh` script](./scripts/uninstall-zabbix-agent.sh) to uninstall the Zabbix agent & purge configuration/log files.

```shell
./scripts/uninstall-zabbix-agent.sh [--force]
```
