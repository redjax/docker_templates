# Zabbix Agent

Compose file for the Zabbix agent. Run this on machines you want to monitor with Zabbix.

## Agent Auto-regsitration

> [!NOTE]
> These steps are accurate as of 2025-12-10, and Zabbix v7.4.5

Copy the [example `.env` file](./.env.example) to `.env`. Set `ZABBIX_AGENT_METADATA_OVERRIDE=autoregister` (and any other tags you want associated with the device). If you want to use a registration token for autoregistration, set the token value in `ZABBIX_REGISTRATION_KEY`.

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


Now when you start the agent container, it should automatically register itself with Zabbix.
