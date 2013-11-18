express = require 'express'
saver = require './saver'

app = express()
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use (err, req, res, next) ->
  res.send 500, "Bad things happened:<br/> #{err.message}"

app.post '/post', (req, res, next) ->
  saver.saveRequest req, (err, filename) ->
    return next err if err?

    console.log 'saved', filename
    res.end()

app.listen 1127
console.log 'Listening on port 1127'
