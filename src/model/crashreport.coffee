path = require 'path'
formidable = require 'formidable'
mkdirp = require 'mkdirp'
fs = require 'fs-extra'
cache = require './cache'
minidump = require 'minidump'
Sequelize = require 'sequelize'
sequelize = require './db'

DIST_DIR = 'pool/files/minidump'

Crashreport = sequelize.define('record', {
  id:
    type: Sequelize.INTEGER
    autoIncrement: yes
    primaryKey: yes
  path: Sequelize.STRING
  product: Sequelize.STRING
  version: Sequelize.STRING
})

Crashreport.sync()

Crashreport.getStackTrace = (record, callback) ->
  return callback(null, cache.get(record.id)) if cache.has record.id

  symbolPaths = [ path.join 'pool', 'symbols' ]
  minidump.walkStack record.path, symbolPaths, (err, report) ->
    cache.set record.id, report unless err?
    callback err, report

Crashreport.createFromRequest = (req, callback) ->
  form = new formidable.IncomingForm()
  form.parse req, (error, fields, files) ->
    unless files.upload_file_minidump?.name?
      return callback new Error('Invalid breakpad upload')

    mkdirp DIST_DIR, (err) ->
      return callback new Error("Cannot create directory: #{dist}") if err?

      sequelize.transaction (t) ->
        props = product: fields.prod, version: fields.ver

        Crashreport.create(props, { transaction: t })
          .then (record) ->
            id = record.get('id').toString()
            filename = path.join DIST_DIR, id
            fs.copySync(files.upload_file_minidump.path, filename)
            record.update({ path: filename }, { transaction: t })
              .then (savedCrashreport) ->
                callback(null, savedCrashreport)

      .catch (err) ->
        callback err

module.exports = Crashreport
