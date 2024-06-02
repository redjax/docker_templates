'use strict'

// Imports
const express = require('express')
// const { get } = require('http')
// const path = require('path')
const favicon = require('serve-favicon')

// My modules
const logs = require('./modules/logger')
// Assign logger module's "logger" function to constant "log"
const log = logs.logger
// Assign logger module's "httpLoger" function to constant "hlog"
const hlog = logs.httpLogger

// Import config file in ./config/app_config.js
var config_file = require('./config/app_config')
// Config file has a confusing nested object modle. Create a variable to "flatten" the first level
var config = config_file.config
// Shortcut to config_file.config.sitevars
const sitevars = config.sitevars
const siteconfig = config.site_config
// const getNestedObject = config_file.getNestedObject
const secrets = config.secrets

log.debug(`App config print: ${JSON.stringify(config)}`)
log.debug(`App sitevars print: ${JSON.stringify(sitevars)}`)
log.debug(`App print: Secrets: ${secrets.secret1}`)


// METHOD 1: the getNestedObject function. Uncomment "const getNestedObject" above
//  if using this method
// var favicon_path = getNestedObject(config, ['site_config', 'favicon_path'])
//
// METHOD 2: access the favicon_path config variable directly.
//  Comment getNestedObject if using this method
var favicon_path = siteconfig.favicon_path

log.debug(`App debug: favicon path: ${favicon_path}`)

// Create express app, port, and host
const app = express()
// Tell app to use logger.httpLogger middleware
app.use(hlog)

// const port = 8080
const port = process.env.NODE_PORT

const host = '0.0.0.0'

// set view engine
const view_engine = 'ejs'
app.set('view engine', view_engine)

// Set static file dir to public/
const static_dir = express.static('public')

// Log NODE_ENV to console if NODE_ENV is not 'production'

// App
const router = express.Router()

// Routes

// index page
router.get('/', (req,res, next) => {

    // Example, pass an array to the page. Check ejs for syntax on looping elements
    var mascots = [
        { name: 'Sammy', organization: "Digital Ocean", birth_year: 2012 },
        { name: 'Tux', organization: "Linux", birth_year: 1996 },
        { name: 'Moby Dock', organization: "Docker", birth_year: 2013 }
    ]

    // When page loads, renders a paragraph with <%= tagline %>
    var tagline = "No programming concept is complete without a cute animal mascot."

    log.debug(mascots)

    // Render pages/index.ejs
    res.status(200).render('pages/index', {
        // pass sitevars to all pages
        sitevars,
        // Assign variables above to new variable, pass to template
        mascots: mascots,
        tagline: tagline
    })
})

// about page
router.get('/about', (req, res) => {

    var example_img = 'img/stream-stones-trees.jpg'

    log.debug(`img: ${example_img}`)

    res.render('pages/about', {
        // pass sitevars to all pages
        sitevars,
        example_img
    })
})

// Example page, demonstrating page components/partials and Bootstrap components
router.get('/examples', (req, res, next) => {
    res.render('pages/examples', {
        sitevars
    })
})

// Example error logging
router.get('/boom', (req, res, next) => {
    try {
        throw new Error('Wowza!')
    } catch (error) {
        log.error(`Whoops! This broke with error: ${error}`)
        res.status(500).send('Error!')
    }
})

router.get('/errorhandler', (req, res, next) => {
    try {
        throw new Error('Wowza!')
    } catch (error) {
        next(error)
    }
})

// Setup router
app.use('/', router)
// Set static directory to './public'
app.use(static_dir)
// Set favicon
app.use(favicon(favicon_path))

// Tell app to use error logging and handling functions
app.use(logErrors)
app.use(errorHandler)

function logErrors(err, req, res, next) {
    // Log errors to console
    console.error(err.stack)
    next(err)
}

function errorHandler (err, req, res, next) {
    // When page cannot resolve, send error message
    res.status(500).send('Error 500')
}

// Only print debug info to console if in development environment
if (process.env.NODE_ENV !== 'production') {
    log.info(`NODE_ENV: ${process.env.NODE_ENV}`)
    log.debug(`.env host: ${host}`)
    log.debug(`.env port: ${port}`)
    log.debug(`view engine: ${view_engine}`)
    log.debug(`sitevars: ${JSON.stringify(sitevars)}`)
    log.debug(`Log file: ${logs.opts.file.filename}`)

    // Print newline on dev to separate logs
    console.log(`\n`)

}

// Run server
app.listen(process.env.NODE_PORT, host || 8080, host)
log.info(`Server running in Docker on http://${host}:${port}`)
