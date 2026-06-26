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
    //   'uv',
    //   'github-actions',
    //   'azure-pipelines',
    //   'gitlabci',
    //   'forgejo-actions',
    //   'gitea-actions',
    //   'dockerfile',
    //   'docker-compose',
    //   'npm',
    //   'pip_requirements',
    //   'poetry',
    //   'pip-compile',
    //   'gomod',
    //   'go-mod-directive',
    // ],

    // Uncomment and tailor these rules as needed.
    // Package manager docs: https://docs.renovatebot.com/configuration-options/#packagerules
    // packageRules: [
    //   {
    //     matchManagers: ['uv'],
    //     groupName: 'Python (uv)',
    //   },
    //   {
    //     matchManagers: ['github-actions'],
    //     groupName: 'GitHub Actions',
    //   },
    //   {
    //     matchManagers: ['azure-pipelines'],
    //     groupName: 'Azure Pipelines',
    //   },
    //   {
    //     matchManagers: ['gitlabci'],
    //     groupName: 'GitLab CI',
    //   },
    //   {
    //     matchManagers: ['dockerfile', 'docker-compose'],
    //     groupName: 'Docker',
    //   },
    //   {
    //     matchManagers: ['gomod'],
    //     groupName: 'Go modules',
    //   },
    //   {
    //     matchManagers: ['npm'],
    //     groupName: 'Node.js',
    //   },
    //   {
    //     matchManagers: ['github-actions'],
    //     matchPackageNames: ['actions/*'],
    //     groupName: 'GitHub Actions core',
    //   },
    //   {
    //     matchManagers: ['npm'],
    //     matchUpdateTypes: ['major'],
    //     groupName: 'Node major updates',
    //   },
    //   {
    //     matchManagers: ['gomod'],
    //     matchUpdateTypes: ['major'],
    //     groupName: 'Go major updates',
    //   },
    // ],
};
