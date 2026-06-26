/*
Copy this file to config/config.json and edit it according to your needs.

For example, change the platform to 'gitlab'
*/

module.exports = {
    // Supported values:
    //   github, gitlab, forgejo, gitea, azure, bitbucket, bitbucket-server.
    // Use one platform per bot instance.
    platform: 'github',
    // Whether Renovate should create onboarding PRs for repos that do not yet
    //   have their own Renovate config file.
    // true  = create onboarding PRs.
    // false = skip onboarding PRs and run using the global bot config.
    onboarding: false,
    // Controls whether a repo must already have its own Renovate config file.
    // required = only run on repos that already have config.
    // optional = run even if the repo has no config file yet.
    // ignored  = ignore repo-local config and rely on bot-level config.
    requireConfig: 'optional',
    // Creates a dashboard issue in the repo & keeps it updated with dependency changes
    dependencyDashboard: true,
    // List of repositories to scan
    repositories: ["username/repo1", "username/repo2"],
    // Uncomment to restrict Renovate to only these manager types.
    // All managers: https://docs.renovatebot.com/modules/manager/
    // enabledManagers: [
    //     'ansible',
    //     'ansible-galaxy',
    //     'crow',
    //     'droneci',
    //     'github-actions',
    //     'gitlabci',
    //     'gitlabci-include',
    //     'woodpecker',
    //     'uv',
    //     'devcontainer',
    //     'docker-compose',
    //     'dockerfile',
    //     'gomod',
    //     'terraform',
    //     'terraform-version',
    //     'terragrunt',
    //     'terragrunt-version',
    //     'tflint-plugin',
    //     'nvm',
    //     'pip_requirements',
    //     'pre-commit',
    //     'git-submodules',
    //     'mise',
    //     'renovate-config'
    // ],

    // Uncomment and tailor these rules as needed.
    // Package manager docs: https://docs.renovatebot.com/configuration-options/#packagerules
    // packageRules: [
    //     {
    //         matchManagers: ['uv'],
    //         groupName: 'Python dependencies',
    //     },
    //     {
    //         matchManagers: ['github-actions'],
    //         groupName: 'GitHub Actions',
    //     },
    //     {
    //         matchManagers: ['dockerfile', 'docker-compose'],
    //         groupName: 'Docker',
    //     },
    //     {
    //         matchManagers: ['gomod'],
    //         groupName: 'Go dependencies',
    //     },
    //     {
    //         matchManagers: ['terraform', 'terraform-version', 'terragrunt', 'terragrunt-version', 'tflint-plugin'],
    //         groupName: 'Terraform',
    //     },
    //     {
    //         matchManagers: ['nvm'],
    //         groupName: 'Node runtime',
    //     },
    //     {
    //         matchManagers: ['pip_requirements', 'pre-commit', 'mise'],
    //         groupName: 'Python tooling',
    //     },
    //     {
    //         matchManagers: ['ansible', 'ansible-galaxy'],
    //         groupName: 'Ansible',
    //     },
    //     {
    //         matchManagers: ['crow', 'droneci', 'gitlabci', 'gitlabci-include', 'woodpecker'],
    //         groupName: 'CI pipelines',
    //     },
    //     {
    //         matchManagers: ['devcontainer', 'renovate-config'],
    //         groupName: 'Dev tooling',
    //     },
    //     {
    //         matchManagers: ['git-submodules'],
    //         groupName: 'Submodules',
    //     },
    // ]
};
