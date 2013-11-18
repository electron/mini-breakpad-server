fs = require 'fs'
path = require 'path'
formidable = require 'formidable'
mkdirp = require 'mkdirp'
uuid = require 'node-uuid'

exports.saveRequest = (req, callback) ->
  form = new formidable.IncomingForm()
  form.parse req, (error, fields, files) ->
    unless files.upload_file_minidump?.name is 'minidump.dmp'
      return callback new Error('Invalid breakpad upload')

    dist = "pool/files/minidump/#{fields.ver}"
    mkdirp dist, (err) ->
      return callback new Error("Cannot create directory: #{dist}") if err?

      filename = path.join dist, uuid.v4()
      fs.rename files.upload_file_minidump.path, filename, (err) ->
        return callback new Error("Cannot create file: #{filename}") if err?

        callback null, filename
