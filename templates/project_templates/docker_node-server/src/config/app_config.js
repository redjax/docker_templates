const path = require('path')
const fs = require('fs')

// My modules
const logs = require('../modules/logger')
const log = logs.logger


const getNestedObject = (nestedObj, pathArr) => {
    // Function to search config objects for a configuration
    // i.e. an object in config.siteconfig like sitevars
    return pathArr.reduce((obj, key) =>
        (obj && obj[key] !== 'undefined') ? obj[key] : undefined, nestedObj);
}

// Declare variables with logic outside of config array
const favicon_path = path.join('public', `favicon/${process.env.NODE_ENV || 'development'}/favicon.ico`)

log.debug(`Favicon path: ${favicon_path}`)

// Empty config array, to store other configs
var config = {}

// Load secret configurations. You need to create an app_secrets.json
// file. I have not built logic to skip if it doesn't exist

let secrets_file = path.join('config', 'confs/app_secrets.json')
log.debug(`App_config print: Secrets file: ${secrets_file}`)
var secrets_import = JSON.parse(fs.readFileSync(secrets_file))
log.debug(`App_config print: Secrets import: ${secrets_import}`)

// Create config.secrets from imported secrets file
config.secrets = secrets_import
// Create "shortcuts" to secrets_import nested objects
var secret_sitevars = config.secrets.secret_sitevars
// var secrets = config.secrets.secrets

// Site/env config
config.site_config = {
    port: process.env.NODE_PORT || 8080,
    site_address: '0.0.0.0',
    favicon_path: favicon_path
}

log.debug(`Config: ${config}`)
log.debug(`Config favicon path: ${config.site_config.favicon_path}`)

// Create an array for config var.
// Call in other files with
config.sitevars = {
    // Set title of site
    'site_title': 'docker_express',
    // Update copyright year every new year
    'copyright_year': new Date().getFullYear(),
    // Footer copyright attribution
    // 'copyright_holder': 'redjax',
    'copyright_holder': `${secret_sitevars.copyright_holder}`,
    // Address, possibly remove in prod
    'site_address': `${config.site_config.site_address}:${config.site_config.port}`
}


module.exports = {
    config,
    getNestedObject
}