formidable = require 'formidable'
uuid = require 'node-uuid'

class Record
  id: null
  time: null
  path: null
  product: null
  version: null
  fields: null

  constructor: ({@id, @time, @path, @product, @version, @fields}) ->
    @id ?= uuid.v4()
    @time ?= Date.now()

  # Public: Returns the presentation to be stored in database.
  getRawPresentation: ->
    time: @time, fields: @fields

  # Public: Parse web request to get the record.
  @createFromRequest: (req, callback) ->
    form = new formidable.IncomingForm()
    form.parse req, (error, fields, files) ->
      unless files.upload_file_minidump?.name is 'minidump.dmp'
        return callback new Error('Invalid breakpad upload')

      record = new Record
        path: files.upload_file_minidump.path
        product: fields.prod
        version: fields.ver
        fields: fields
      callback(null, record)

module.exports = Record
