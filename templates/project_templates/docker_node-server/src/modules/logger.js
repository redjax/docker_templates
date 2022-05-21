const winston = require('winston')
const morgan = require('morgan')
const json = require('morgan-json')


// WINSTON
const options = {
    file: {
        level: process.env.LOG_LEVEL || 'info',
        filename: './logs/app.log',
        handleExceptions: true,
        json: true,
        maxsize: 5242880,  // 5MB
        maxFiles: 5,
        colorize: false,
    },
    console: {
        level: 'debug',
        handleExceptions: true,
        json: false,
        colorize: true,
    },
}

const logger = winston.createLogger({
    levels: winston.config.npm.levels,
    transports: [
        new winston.transports.File(options.file),
        new winston.transports.Console(options.console)
    ],
    exitOnError: false
})

// MORGAN HTTP LOGS
const format = json({
    method: ':method',
    url: ':url',
    status: 'status',
    contentLength: ':res[content-length]',
    responseTime: ':response-time'
})

const httpLogger = morgan(format, {
    stream: {
        write: (message) => {
            const {
                method,
                url,
                status,
                contentLength,
                responseTime
            } = JSON.parse(message)

            logger.info('HTTP Access Log', {
                timestamp: new Date().toString(),
                method,
                url,
                status: Number(status),
                contentLength,
                responseTime: Number(responseTime)
            })
        }
    }
})


module.exports = {
    logger,
    httpLogger,
    opts: options
}