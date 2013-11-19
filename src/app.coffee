path = require 'path'
express = require 'express'
reader = require './reader'
saver = require './saver'
Database = require './database'

app = express()

db = new Database
db.on 'load', ->
  app.listen 1127
  console.log 'Listening on port 1127'

app.set 'views', path.resolve(__dirname, '..', 'views')
app.set 'view engine', 'jade'
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use (err, req, res, next) ->
  res.send 500, "Bad things happened:<br/> #{err.message}"

app.post '/post', (req, res, next) ->
  saver.saveRequest req, db, (err, filename) ->
    return next err if err?

    console.log 'saved', filename
    res.end()

app.get '/', (req, res, next) ->
  res.render 'index', title: 'Crash Reports', records: db.getAllRecords()

app.get '/view/:id', (req, res, next) ->
  db.restoreRecord req.params.id, (err, record) ->
    return next err if err?

    reader.getStackTraceFromRecord record, (err, report) ->
      return next err if err?
      res.render 'view', {title: 'Crash Report', report}
