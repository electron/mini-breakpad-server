bodyParser = require 'body-parser'
methodOverride = require('method-override')
path = require 'path'
express = require 'express'
WebHook = require './webhook'
Record = require './record'

app = express()
webhook = new WebHook

app.set 'views', path.resolve(__dirname, '..', 'views')
app.set 'view engine', 'jade'
app.use bodyParser.json()
app.use bodyParser.urlencoded({extended: true})
app.use methodOverride()
app.use (err, req, res, next) ->
  res.send 500, "Bad things happened:<br/> #{err.message}"

app.post '/webhook', (req, res, next) ->
  webhook.onRequest req

  console.log 'webhook requested', req.body.repository.full_name
  res.end()

app.post '/post', (req, res, next) ->
  Record.createFromRequest req, (err, record) ->
    return next err if err?
    res.json record
    res.end()

root =
  if process.env.MINI_BREAKPAD_SERVER_ROOT?
    "#{process.env.MINI_BREAKPAD_SERVER_ROOT}/"
  else
    ''

app.get "/#{root}", (req, res, next) ->
  Record.findAll().then (records) ->
    res.render 'index', title: 'Crash Reports', records: records

app.get "/#{root}view/:id", (req, res, next) ->
  Record.findById(req.params.id).then (record) ->
    if not record?
      return res.send 404, 'Crash report not found'
    Record.getStackTrace record, (err, report) ->
      res.render 'view', { title: 'Crash Report', report: report, fields: record.toJSON() }

port = process.env.MINI_BREAKPAD_SERVER_PORT ? 1127
app.listen port
console.log "Listening on port #{port}"
