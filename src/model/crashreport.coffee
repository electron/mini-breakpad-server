path = require 'path'
formidable = require 'formidable'
mkdirp = require 'mkdirp'
fs = require 'fs-promise'
cache = require './cache'
minidump = require 'minidump'
Sequelize = require 'sequelize'
sequelize = require './db'
nconf = require 'nconf'
tmp = require 'tmp'

DIST_DIR = 'pool/files/minidump'

# custom fields should have 'files' and 'params'
customFields = nconf.get('customFields') || {}

schema =
  id:
    type: Sequelize.INTEGER
    autoIncrement: yes
    primaryKey: yes
  product: Sequelize.STRING
  version: Sequelize.STRING
  upload_file_minidump: Sequelize.BLOB

for field in (customFields.params || [])
  schema[field] = Sequelize.STRING

for field in (customFields.files || [])
  schema[field] = Sequelize.BLOB

Crashreport = sequelize.define('crashreports', schema)

Crashreport.sync()

Crashreport.getStackTrace = (record, callback) ->
  return callback(null, cache.get(record.id)) if cache.has record.id

  symbolPaths = [ path.join 'pool', 'symbols' ]

  tmpfile = tmp.fileSync()
  fs.writeFile(tmpfile.name, record.upload_file_minidump).then ->
    minidump.walkStack tmpfile.name, symbolPaths, (err, report) ->
      tmpfile.removeCallback()
      cache.set record.id, report unless err?
      callback err, report
  .catch (err) ->
    tmpfile.removeCallback()
    callback err

Crashreport.createFromRequest = (req, callback) ->
  form = new formidable.IncomingForm()
  form.parse req, (error, fields, files) ->
    unless files.upload_file_minidump?.name?
      return callback new Error('Invalid breakpad upload')

    props = product: fields.prod, version: fields.ver

    for param in customFields.params
      if param of fields
        props[param] = fields[param]

    fileOps = []
    fileParams = customFields.files.concat(['upload_file_minidump'])

    for fileParam in fileParams
      if fileParam of files
        p = fs.readFile(files[fileParam].path).then (contents) ->
          props[fileParam] = contents

        fileOps.push(p)

    Promise.all(fileOps).then( ->
      Crashreport.create(props).then (crashreport) ->
        callback(null, crashreport)
    ).catch (err) ->
      callback err

module.exports = Crashreport
