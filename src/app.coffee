nconf = require 'nconf'
nconf.formats.yaml = require 'nconf-yaml'

nconf.defaults
  port: process.env.BREAKPAD_PORT || 1127
  baseUrl: process.env.BASEURL || '/'
  database:
    host: 'localhost'
    dialect: 'sqlite'
    storage: 'database.sqlite'
    logging: no

nconf.file 'user', {
  file: './breakpad-server.yaml', format: nconf.formats.yaml
}
nconf.file 'system', {
  file: '/etc/breakpad-server.yaml', format: nconf.formats.yaml
}

bodyParser = require 'body-parser'
methodOverride = require('method-override')
path = require 'path'
express = require 'express'
exphbs = require 'express-handlebars'
WebHook = require './webhook'
Crashreport = require './model/crashreport'
Symfile = require './model/symfile'

# initialization: write all symfiles to disk
Symfile.findAll()
  .then (symfiles) ->
    Promise.all(symfiles.map((s) -> Symfile.saveToDisk(s))).then(run)
  .catch (err) ->
    console.log "could not save symfiles to disk: #{err.message}"

run = ->
  app = express()
  breakpad = express()
  webhook = new WebHook

  breakpad.set 'views', path.resolve(__dirname, '..', 'views')
  breakpad.engine('handlebars', exphbs({defaultLayout: 'main'}))
  breakpad.set 'view engine', 'handlebars'
  breakpad.use bodyParser.json()
  breakpad.use bodyParser.urlencoded({extended: true})
  breakpad.use methodOverride()

  baseUrl = nconf.get('baseUrl')
  port = nconf.get('port')

  app.use baseUrl, breakpad

  # serve minidumps as files
  breakpad.use '/minidumps', express.static('pool/files/minidump')

  # error handler
  app.use (err, req, res, next) ->
    if not err.message?
      console.log 'warning: error thrown without a message'

    res.status(500).send "Bad things happened:<br/> #{err.message || err}"

  breakpad.post '/webhook', (req, res, next) ->
    webhook.onRequest req

    console.log 'webhook requested', req.body.repository.full_name
    res.end()

  breakpad.post '/crashreports', (req, res, next) ->
    Crashreport.createFromRequest req, (err, record) ->
      return next err if err?
      res.json record

  breakpad.get '/', (req, res, next) ->
    res.redirect '/crashreports'

  breakpad.get '/crashreports', (req, res, next) ->
    Crashreport.findAll(order: 'createdAt DESC').then (records) ->
      res.render 'index', title: 'Crash Reports', records: records

  breakpad.get '/crashreports/:id', (req, res, next) ->
    Crashreport.findById(req.params.id).then (record) ->
      if not record?
        return res.send 404, 'Crash report not found'
      Crashreport.getStackTrace record, (err, report) ->
        res.render 'view', { title: 'Crash Report', report: report, fields: record.toJSON() }

  breakpad.post '/symfiles', (req, res, next) ->
    Symfile.createFromRequest req, (err, symfile) ->
      return next(err) if err?
      symfileJson = symfile.toJSON()
      delete symfileJson.contents
      res.json symfileJson

  app.listen port
  console.log "Listening on port #{port}"
