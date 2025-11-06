# Jotty

[Jotty](https://github.com/fccview/jotty?utm_source=chatgpt.com) is a simple, self-hosted app for checklists & notes. Alternative to cloud-based to-do apps like Todoist or Trello.

## Setup 

Run the [`init-setup.sh` script](./scripts/init-setup.sh) to create the initial directories and set permissions. Alternatively, run the commands below:


```shell
mkdir -p jotty/{data,config,cache}
chown -R 1000:1000 ./jotty
```
