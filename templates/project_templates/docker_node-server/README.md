**NOTE**: Check the [dev branch](https://gitlab.com/redjax/docker_node-server/-/tree/dev) for latest code. Also check dev_* branches for feature development (they may not exist if no feature is being actively developed)

# [WIP] Instructions

> NOTE: This project assumes you have [docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/) installed.

1. Clone repo
  * $>git clone https://gitlab.com/redjax/docker_node-server.git
2. Run initial_setup script
  * $> cd docker_node-server
  * $> ./initial_setup.sh
3. Edit .env
  * Any required variables will be in the "Required" section
4. Edit src/config/confs/*.json
  * This file is created from an example. 
    * Certain values are there as an example
    * Build the secrets file from scratch after cloning if you have, i.e. an API key
5. Build the container
  * $>docker-compose build
6. Run the stack
  * $>docker-compose up -d
  * (OPTIONAL) you can do steps 5 and 6 in one with:
    * $>docker-compose up -d --build
  
Access the site from http://your-ip:port  (default port is 8080)
  i.e. http://192.168.1.124:8080 or http://localhost:8080 (if running stack locally)

# [WIP] Description

*I will try to keep the master branch's README up to date with changes merged from rc.*

The project has 2 states: 
* production
* dev/development

Update "NODE_TARGET" and "NODE_ENV" in the .env file to switch between the environments.


    NOTE: Make sure to read the comment above the NODE_{TARGET,ENV} variables in .env. One will not accept dev, the other will *only* accept dev.


### When making changes to the Dockerfile, or any major changes in the app, run ./dc_rebuild.sh to rebuild the environment

# [WIP] Production environment

# [WIP] Dev/Development environment
## Packages:

* nodemon
  * For live updates to the server, i.e. package installs without needing to rebuild
* livereload
  * For live-updating server's html/return statements

# Branches
Different branches will help separate different working states of the base server. I'm going to try to move to tags eventually

* master
  * should always be in a working state
  * cannot push, only merge
* rc
  * changes from dev get merged for refinement
  * ensure branch is in a working state before merging into master
* dev
  * unstable branch
  * new features are branched from this branch, then merged back for further development before merging into rc

## | master/rc/dev
*Further developing an express boilerplate*

```
Create new feature branch:

$>./auto_git_checkout dev
$>git checkout -b dev_feature

where "dev_feature" is a new feature you want to work on, i.e. dev_database (for adding a database to the project)

When done working on a new feature, merge back to the dev branch and optionally delete the dev_feature branch
```

---

# [WIP] Features

## Config parsing

The src/config/*_config.js files create configurations for the app to read. (( write a more detailed overview ))

===

### Structure of config objects

This section describes the functionality of parsing config files in src/config

> config/app_config.js

Starts with an empty config object, config = {}

Each new type of config object (i.e. site_config) is created like:
```
config = {}

config.site_config = {
  key1: 'val1',
  key2: 'val2'
}
```

app.js imports and uses app_config.js like:

```
var config_file = require('./config/app_config')

var config = config_file.config  // make config var the first level of config objects
const sitevars = config.sitevars  // make sitevars var the sitevars object in config.sitevars

// Access a variable in sitevars
var site_title = sitevars.site_title  // Will use whatever is set in config.sitevars.site_title
```

Optional: Access object variables using getNestedObject function. (better instructions when I move this to app_config.js)

```
const getNestedObject = (nestedObj, pathArr) => {
    // Function to search config objects for a configuration
    // i.e. an object in config.siteconfig like sitevars
    return pathArr.reduce((obj, key) =>
        (obj && obj[key] !== 'undefined') ? obj[key] : undefined, nestedObj);
}

// Access a variable by searching an object by path for variable
//    Returns undefined if not found
var favicon_path = getNestedObject(config, ['site_config', 'favicon_path'])
```

---

## Logging
*TODO: write useful stuff about logging module here*

---
# Useful links

I've found these links helpful in one way or another throughout this project

1. [DigitalOcean - How to use ejs to template your node application](https://www.digitalocean.com/community/tutorials/how-to-use-ejs-to-template-your-node-application)
2. [Medium - EJS partials](https://medium.com/@henslejoseph/ejs-partials-f6f102cb7433)
3. [First guide I was able to get a container to actually run](https://www.digitalocean.com/community/tutorials/how-to-build-a-node-js-application-with-docker)
4. [This looks like a useful guide for setting up NGINX when I'm ready to do that](https://ashwin9798.medium.com/nginx-with-docker-and-node-js-a-beginners-guide-434fe1216b6b)
5. [Sematext - Node JS Logging](https://sematext.com/blog/node-js-logging/)
