# N8N <!-- omit in toc -->

[n8n](https://github.com/n8n-io/n8n) is a no-code/low-code workflow automation builder. It's like a free, self-hostable Zapier.

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [Quickstart](#quickstart)
  - [LAN Setup](#lan-setup)
  - [Proxied Setup](#proxied-setup)
- [Overlays](#overlays)
  - [Traefik](#traefik)
  - [NocoDB](#nocodb)
    - [Test Connectivity](#test-connectivity)

## Setup

TODO:

- [ ] Write LAN setup docs
  - [ ] Running just the n8n container locally
  - [ ] Running n8n and overlay(s)
  - [ ] Document env vars
- [ ] Write proxied setup docs
  - [ ] Document setup with Pangolin
- [ ] Detail OAuth2 connections
  - [ ] Document Gmail OAuth2 setup

### Quickstart

Quickstart steps for running a local/LAN only instance of n8n with no bells & whistles.

- Copy the [example `.env`](./.env.example) to `.env`
  - Set your timezone in `TZ`
- Generate an encryption key by running [`./scripts/generate_encryption_key.sh`](./scripts/generate_encryption_key.sh)
- Set `N8N_HOST` to `http://192.168.1.xxx:5678`
  - If you set a different port in `N8N_WEBUI_PORT`, use that port instead of `:5678`
- Run `docker compose pull && docker compose up -d`
- Access the `n8n` webUI at `http://192.168.1.xxx:5678` (or whatever port you set)
  - Login to the admin account (default: `n8n`/`n8nadmin`)

### LAN Setup

### Proxied Setup

## Overlays

You can run `n8n` on its own with just `docker compose up -d`, but there are a number of [optional overlays](./overlays/) you can run as well.

> [!WARNING]
> The [traefik overlay](./overlays/traefik.yml) is essentially useless until I spend time actually setting it up.

### Traefik

*[traefik overlay](./overlays/traefik.yml)*

### NocoDB

*[NocoDB overlay](./overlays/nocodb.yml)*

`n8n` has a NocoDB connector, which means you can use it as a backend for your workflows. NocoDB is similar to Airtable, and provides a NoSQL interface for accessing tabular data.

The overlay includes a Postgres database for the NocoDB backend. To use it with `n8n`, create an API key by navigating to Account Settings -> Tokens and use it for authentication in the `n8n` NocoDB node.

For the NocoDB URL, you can use the container's hostname, i.e. `http://nocodb:8080`.

> [!TIP]
> To simplify some of the setup, there is a [`first_run.sh` script](./scripts/nocodb/first_run.sh) that helps to get up and running by generating passwords and optionally creating the host volume mount ahead of time (to avoid permission errors).

#### Test Connectivity

After creating a credential in `n8n` for NocoDB, paste this into a new workflow (replace `"NocoDB Token account"` with the name you gave the credentials in `n8n`):

```json
{
  "nodes": [
    {
      "parameters": {},
      "type": "n8n-nodes-base.manualTrigger",
      "typeVersion": 1,
      "position": [
        0,
        0
      ],
      "id": "7d87a464-9acd-4ae9-bad3-15bb180400a0",
      "name": "When clicking ‘Execute workflow’"
    },
    {
      "parameters": {
        "authentication": "nocoDbApiToken",
        "operation": "getAll",
        "projectId": "p9z58c4zbzocpr8",
        "table": "msf31jkr4yao2ox",
        "returnAll": true,
        "options": {}
      },
      "type": "n8n-nodes-base.nocoDb",
      "typeVersion": 3,
      "position": [
        224,
        0
      ],
      "id": "7ac1d995-da0c-4f13-a9ea-c10a22a6f0aa",
      "name": "List rows in table",
      "credentials": {
        "nocoDbApiToken": {
          "id": "lEJcAHO24B4r8cvF",
          "name": "NocoDB Token account"
        }
      }
    },
    {
      "parameters": {
        "authentication": "nocoDbApiToken",
        "operation": "update",
        "projectId": "p9z58c4zbzocpr8",
        "table": "msf31jkr4yao2ox",
        "fieldsUi": {
          "fieldValues": [
            {
              "fieldName": "=ConnectSuccess",
              "fieldValue": "={{ true }}"
            },
            {
              "fieldName": "Id",
              "fieldValue": "={{ $json.Id }}"
            },
            {
              "fieldName": "Connections",
              "fieldValue": "={{ $json.Connections + 1 }}"
            }
          ]
        }
      },
      "type": "n8n-nodes-base.nocoDb",
      "typeVersion": 3,
      "position": [
        448,
        0
      ],
      "id": "b5410065-55e7-4ee1-a386-75f2473440c1",
      "name": "Update connected col",
      "credentials": {
        "nocoDbApiToken": {
          "id": "lEJcAHO24B4r8cvF",
          "name": "NocoDB Token account"
        }
      }
    },
    {
      "parameters": {
        "authentication": "nocoDbApiToken",
        "operation": "update",
        "projectId": "p9z58c4zbzocpr8",
        "table": "msf31jkr4yao2ox",
        "fieldsUi": {
          "fieldValues": [
            {
              "fieldName": "=ConnectSuccess",
              "fieldValue": "={{ false }}"
            },
            {
              "fieldName": "Id",
              "fieldValue": "={{ $json.Id }}"
            },
            {
              "fieldName": "Connections",
              "fieldValue": "={{ $json.Connections + 1}}"
            }
          ]
        }
      },
      "type": "n8n-nodes-base.nocoDb",
      "typeVersion": 3,
      "position": [
        1056,
        0
      ],
      "id": "102e57a4-ad09-4ebf-9a46-ff7e1261bf20",
      "name": "Reset connected col",
      "credentials": {
        "nocoDbApiToken": {
          "id": "lEJcAHO24B4r8cvF",
          "name": "NocoDB Token account"
        }
      }
    },
    {
      "parameters": {
        "authentication": "nocoDbApiToken",
        "operation": "getAll",
        "projectId": "p9z58c4zbzocpr8",
        "table": "msf31jkr4yao2ox",
        "returnAll": true,
        "options": {}
      },
      "type": "n8n-nodes-base.nocoDb",
      "typeVersion": 3,
      "position": [
        832,
        0
      ],
      "id": "67ceb257-cd5e-4c0d-a9ca-65d19f764466",
      "name": "List rows in table for reset",
      "credentials": {
        "nocoDbApiToken": {
          "id": "lEJcAHO24B4r8cvF",
          "name": "NocoDB Token account"
        }
      }
    },
    {
      "parameters": {
        "content": "## NocoDB Example Instructions\n\n**This workflow assumes you have a NocoDB overlay container in the same Compose stack, or access to a NocoDB database by URL & API token.**\n\nConnects to a NocoDB table (that you create) and updates values. 30 seconds after updating the value, another connection will start to reset it.\n\nIncrements a `Connections` column each time a value is updated.\n\n### Setup\n\n#### NocoDB Setup\n\n- Create an API token\n  - Navigate to Account Settings -> Tokens\n- Create a base named \"N8n Demo\"\n- In the new base, create a table named \"ExampleTbl\"\n  - Add a string column named \"Contents\"\n  - Add a checkbox column named \"Connected\"\n    - Leave the default as unchecked\n  - Add a number column named \"Connections\"\n    - Set a default value of 0\n  - Create a new row by clicking in the cell below \"Title\" and add \"message\" in the cell\n    - In the \"Contents\" cell, add \"Hello, n8n!\"\n\n#### N8N Setup\n\n- In N8N, create a new Credential named \"NocoDB Token account\" using the token you created in NocoDB\n- Execute the workflow\n",
        "height": 720,
        "width": 1008,
        "color": 5
      },
      "type": "n8n-nodes-base.stickyNote",
      "position": [
        -1088,
        -224
      ],
      "typeVersion": 1,
      "id": "b95570bb-d462-404a-8c92-9722b1ee8800",
      "name": "Sticky Note"
    },
    {
      "parameters": {
        "amount": 30
      },
      "type": "n8n-nodes-base.wait",
      "typeVersion": 1.1,
      "position": [
        640,
        0
      ],
      "id": "5f6d9a66-3c83-41d5-8067-297508478390",
      "name": "Wait 30 seconds",
      "webhookId": "eaa47691-77c5-4218-8763-311da0fb8e25"
    }
  ],
  "connections": {
    "When clicking ‘Execute workflow’": {
      "main": [
        [
          {
            "node": "List rows in table",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "List rows in table": {
      "main": [
        [
          {
            "node": "Update connected col",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Update connected col": {
      "main": [
        [
          {
            "node": "Wait 30 seconds",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "List rows in table for reset": {
      "main": [
        [
          {
            "node": "Reset connected col",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Wait 30 seconds": {
      "main": [
        [
          {
            "node": "List rows in table for reset",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {},
  "meta": {
    "templateCredsSetupCompleted": true,
    "instanceId": "21ec9616dd0819c24cf9583355b8ed3ad9945b4ddd328093e2557daf21e35aba"
  }
}
```
