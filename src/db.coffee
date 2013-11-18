path = require 'path'
dirty = require 'dirty'
mkdirp = require 'mkdirp'
{EventEmitter} = require 'events'

class Database extends EventEmitter
  db: null

  # Public: Create a new Database with path to {filename}
  constructor: (filename) ->
    dist = path.resolve filename, '..'
    mkdirp dist, (err) =>
      throw new Error("Cannot create directory: #{dist}") if err?

      @db = dirty filename
      @db.on 'load', @emit.bind(this, 'load')

  # Public: Save a record to database.
  saveRecord: (record, callback) ->
    @db.set record.id, record
    callback null

# Public: Create a new Database whose name is {name}
module.exports = (name='database') ->
  new Database(path.join 'pool', 'database', 'dirty', name)
