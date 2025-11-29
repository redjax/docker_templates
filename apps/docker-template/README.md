# Docker Templates CLI <!-- omit in toc -->

A CLI app for interacting with this repository.

## Table of Contents <!-- omit in toc -->

- [Planned Functionality](#planned-functionality)
  - [Environment features](#environment-features)
  - [CLI Features](#cli-features)
  - [Releases](#releases)

## Planned Functionality

An overview of features/functionality I have planned for this app.

### Environment features

- [ ] Config
  - [ ] `~/.docker_templates/`
  - [ ] Support for `~/.docker_templates/config.yml` config file
- [ ] Data/repo dir
  - [ ] Clone the repository's `main` branch to `~/.docker_templates/repo`
  - [ ] Allow configuring the repository/data directory

### CLI Features

- [ ] Initialize a new template
  - [ ] Cookiecutter
  - [ ] Prompt user for new template inputs
    - [ ] - [ ] Template category (a subdirectory in [the `templates/` path](../../templates/))
    - [ ] Template name
    - [ ] Template shortname (normalized, with `docker_` prepended)
    - [ ] Template summary (short description of template for top of the `README.md`)
    - [ ] Template description (optional longer description for the template)
- [ ] Template browser
  - [ ] Local
    - [ ] Use the [`metadata/` files](../../metadata/) and [repository map](../../map/)
  - [ ] Remote
    - [ ] Use HTTP requests to scrape the metadata and repository map files
  - [ ] [Bubbletea](https://github.com/charmbracelet/bubbletea)/[]/[Bubbles](https://github.com/charmbracelet/bubbles) TUI
    - [ ] Browse with keyboard
    - [ ] Preview files
    - [ ] Create sparse clone
    - [ ] Download archive of individual templates
      - [ ] Allow multi-select
- [ ] Local development helpers
  - [ ] Git operations
    - [ ] Worktrees
      - [ ] Create in `~/.docker_templates/worktrees/`
      - [ ] Allow configuring the git worktree directory
    - [ ] Sparse clones
      - [ ] Create a sparse clone at `./`, or a path with `-o/--output`

### Releases

- [ ] Build pipelines
  - [ ] Github Action
  - [ ] Dagger
  - [ ] Gitlab
- [ ] Goreleaser for multiple apps/platforms
