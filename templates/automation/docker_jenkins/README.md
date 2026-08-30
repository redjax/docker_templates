# Jenkins CI/CD <!-- omit in toc -->

[Jenkins](https://www.jenkins.io) is the OG CI/CD automation server.

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [Retrieve admin password](#retrieve-admin-password)
  - [Connect with a Personal Access Token (PAT)](#connect-with-a-personal-access-token-pat)
    - [PAT Permissions Table](#pat-permissions-table)

## Setup

### Retrieve admin password

During the first boot, you will see log lines with the admin password, and a hint telling you where to find it in the container:

```shell
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> Jenkins initial setup is required. An admin user has been created and a password generated.
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> Please use the following password to proceed to installation:
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> 
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> 
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```

### Connect with a Personal Access Token (PAT)

If you do not need the webhook functionality a Github App provides, you can also just use a PAT.

#### PAT Permissions Table

| Permission                                  | Required/Optional                                     | Purpose                                                                                                       |
| ------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Repository contents                         | Required                                              | Lets Jenkins clone the repo and read files like Jenkinsfile github.                                           |
| Repository metadata                         | Required                                              | Lets Jenkins discover repo/basic information; this is commonly needed for GitHub API interactions github.     |
| Pull requests                               | Optional                                              | Useful if Jenkins needs to inspect PRs or run PR-based multibranch jobs github.                               |
| Commit statuses                             | Optional, useful                                      | Lets Jenkins update the commit status shown in GitHub after a build cloudbees.                                |
| Checks                                      | Optional, useful                                      | Lets Jenkins create GitHub check runs/checks output instead of only commit statuses github.                   |
| Workflows                                   | Usually not needed                                    | Only needed if Jenkins is directly managing GitHub Actions workflows, which is uncommon for Jenkins github.   |
| Contents: write                             | Optional, only if you push tags/commits               | Needed if Jenkins will write back to the repo, such as tagging releases or committing generated files github. |
| Pull requests: write                        | Optional, only if Jenkins comments or edits PRs       | Needed if Jenkins will modify PR state or write PR-related data github.                                       |
| Administration / repository hook management | Optional, only if Jenkins must create/manage webhooks | Needed if you want Jenkins to manage repository hooks rather than setting them manually cloudbees.            |
| Organization permissions                    | Usually not needed                                    | Only needed if Jenkins needs org-level data such as teams or organization resources github.                   |
| Account permissions                         | Usually not needed                                    | Mostly relevant for user-auth/login flows, not normal Jenkins checkout jobs github.                           |
