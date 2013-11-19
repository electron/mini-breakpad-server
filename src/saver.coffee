fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
Record = require './record'

exports.saveRequest = (req, db, callback) ->
  Record.createFromRequest req, (err, record) ->
    return callback new Error("Invalid breakpad request") if err?

    dist = "pool/files/minidump/#{record.version}"
    mkdirp dist, (err) ->
      return callback new Error("Cannot create directory: #{dist}") if err?

      filename = path.join dist, record.id
      fs.rename record.path, filename, (err) ->
        return callback new Error("Cannot create file: #{filename}") if err?

        record.path = filename
        db.saveRecord record, (err) ->
          return callback new Error("Cannot save record to database") if err?

          callback null, filename
