path = require 'path'
formidable = require 'formidable'
mkdirp = require 'mkdirp'
fs = require 'fs-extra'
cache = require './cache'
minidump = require 'minidump'
Sequelize = require 'sequelize'
sequelize = require './db'

DIST_DIR = 'pool/files/minidump'

Record = sequelize.define('record', {
  id:
    type: Sequelize.INTEGER
    autoIncrement: yes
    primaryKey: yes
  path: Sequelize.STRING
  product: Sequelize.STRING
  version: Sequelize.STRING
})

Record.sync

Record.getStackTrace = (record, callback) ->
  return callback(null, cache.get(record.id)) if cache.has record.id

  symbolPaths = [ path.join 'pool', 'symbols' ]
  minidump.walkStack record.path, symbolPaths, (err, report) ->
    cache.set record.id, report unless err?
    callback err, report

Record.createFromRequest = (req, callback) ->
  form = new formidable.IncomingForm()
  form.parse req, (error, fields, files) ->
    unless files.upload_file_minidump?.name?
      return callback new Error('Invalid breakpad upload')

    mkdirp DIST_DIR, (err) ->
      return callback new Error("Cannot create directory: #{dist}") if err?

      sequelize.transaction (t) ->
        props = product: fields.prod, version: fields.ver

        Record.create(props, { transaction: t })
          .then (record) ->
            id = record.get('id').toString()
            filename = path.join DIST_DIR, id
            fs.copySync(files.upload_file_minidump.path, filename)
            record.update({ path: filename }, { transaction: t })
              .then (savedRecord) ->
                callback(null, savedRecord)

      .catch (err) ->
        callback err

module.exports = Record
