path = require 'path'
express = require 'express'
reader = require './reader'
saver = require './saver'
Database = require './database'
WebHook = require './webhook'

app = express()
webhook = new WebHook

db = new Database
db.on 'load', ->
  port = process.env.MINI_BREAKPAD_SERVER_PORT ? 1127
  app.listen port
  console.log "Listening on port #{port}"

app.set 'views', path.resolve(__dirname, '..', 'views')
app.set 'view engine', 'jade'
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use (err, req, res, next) ->
  res.send 500, "Bad things happened:<br/> #{err.message}"

app.post '/webhook', (req, res, next) ->
  webhook.onRequest req

  console.log 'webhook requested', req.body.repository.full_name
  res.end()

app.post '/post', (req, res, next) ->
  saver.saveRequest req, db, (err, filename) ->
    return next err if err?

    console.log 'saved', filename
    res.send path.basename(filename)
    res.end()

root =
  if process.env.MINI_BREAKPAD_SERVER_ROOT?
    "#{process.env.MINI_BREAKPAD_SERVER_ROOT}/"
  else
    ''

app.get "/#{root}", (req, res, next) ->
  res.render 'index', title: 'Crash Reports', records: db.getAllRecords()

app.get "/#{root}view/:id", (req, res, next) ->
  db.restoreRecord req.params.id, (err, record) ->
    return next err if err?

    reader.getStackTraceFromRecord record, (err, report) ->
      return next err if err?
      fields = record.fields
      res.render 'view', {title: 'Crash Report', report, fields}
