path = require 'path'
formidable = require 'formidable'
uuid = require 'node-uuid'

class Record
  id: null
  time: null
  path: null
  product: null
  version: null
  fields: null

  constructor: ({@id, @time, @path, @sender, @product, @version, @fields}) ->
    @id ?= uuid.v4()
    @time ?= new Date

  # Public: Parse web request to get the record.
  @createFromRequest: (req, callback) ->
    form = new formidable.IncomingForm()
    form.parse req, (error, fields, files) ->
      unless files.upload_file_minidump?.name?
        return callback new Error('Invalid breakpad upload')

      record = new Record
        path: files.upload_file_minidump.path
        sender: {ua: req.headers['user-agent'], ip: Record.getIpAddress(req)}
        product: fields.prod
        version: fields.ver
        fields: fields
      callback(null, record)

  # Public: Restore a Record from raw representation.
  @unserialize: (id, representation) ->
    new Record
      id: id
      time: new Date(representation.time)
      path: representation.path
      sender: representation.sender
      product: representation.fields.prod
      version: representation.fields.ver
      fields: representation.fields

  # Private: Gets the IP address from request.
  @getIpAddress: (req) ->
    req.headers['x-forwarded-for'] || req.connection.remoteAddress

  # Public: Returns the representation to be stored in database.
  serialize: ->
    time: @time.getTime(), path: @path, sender: @sender, fields: @fields

module.exports = Record
