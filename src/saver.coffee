fs = require 'fs'
path = require 'path'
formidable = require 'formidable'
mkdirp = require 'mkdirp'
uuid = require 'node-uuid'

exports.saveRequest = (req, database, callback) ->
  form = new formidable.IncomingForm()
  form.parse req, (error, fields, files) ->
    unless files.upload_file_minidump?.name is 'minidump.dmp'
      return callback new Error('Invalid breakpad upload')

    dist = "pool/files/minidump/#{fields.ver}"
    mkdirp dist, (err) ->
      return callback new Error("Cannot create directory: #{dist}") if err?

      id = uuid.v4()
      filename = path.join dist, id
      fs.rename files.upload_file_minidump.path, filename, (err) ->
        return callback new Error("Cannot create file: #{filename}") if err?

        record = id: id, version: fields.ver, product: fields.prod
        database.saveRecord record, (err) ->
          return callback new Error("Cannot save record to database") if err?

          callback null, filename
