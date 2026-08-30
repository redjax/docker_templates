# Jenkins Agent

*[Jenkins agent Github](https://github.com/jenkinsci/docker-agents).*

An [Agent](https://www.jenkins.io/doc/book/using/using-agents/) executes work items sent by the controller, like a Github Actions runner.

## Setting up an agent

In the Jenkins webUI, create a new node/agent and give it a name. You should avoid spaces, using `kebab-casing` instead. Set the `JENKINS_AGENT_NAME` in the [`.env` file](./.env.example). After creating the agent in Jenkins, you will see CLI commands to run the agent. Copy the token from the command and paste it in the `JENKINS_SECRET` variable. Set the Jenkins server address to your server's IP or FQDN, i.e. `https://jenkins.example.com` or `http://192.168.1.xxx:8080`.
