path = require 'path'
dirty = require 'dirty'
mkdirp = require 'mkdirp'
{EventEmitter} = require 'events'
Record = require './record'

class Database extends EventEmitter
  db: null

  # Public: Create or open a Database with path to {filename}
  constructor: (filename=path.join('pool', 'database', 'dirty', 'db')) ->
    dist = path.resolve filename, '..'
    mkdirp dist, (err) =>
      throw new Error("Cannot create directory: #{dist}") if err?

      @db = dirty filename
      @db.on 'load', @emit.bind(this, 'load')

  # Public: Saves a record to database.
  saveRecord: (record, callback) ->
    @db.set record.id, record.serialize()
    callback null

  # Public: Restore a record from database according to its id.
  restoreRecord: (id, callback) ->
    raw = @db.get(id)
    return callback new Error("Record is not in database") unless raw?

    callback null, Record.unserialize(id, @db.get(id))

  # Public: Returns all records as an array.
  getAllRecords: ->
    records = []
    @db.forEach (id, record) -> records.push Record.unserialize(id, record)
    records.reverse()

module.exports = Database
