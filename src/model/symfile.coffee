Sequelize = require 'sequelize'
sequelize = require './db'
formidable = require 'formidable'
fs = require 'fs-promise'

DIST_DIR = 'pool/symbols'

Symfile = sequelize.define('symfiles', {
  id:
    type: Sequelize.INTEGER
    autoIncrement: yes
    primaryKey: yes
  os: Sequelize.STRING
  code: Sequelize.STRING
  arch: Sequelize.STRING
  contents: Sequelize.TEXT
})

Symfile.sync(force: yes)

Symfile.saveToDisk = (symfile, callback) ->
  console.log('todo')

Symfile.createFromRequest = (req, callback) ->
  form = new formidable.IncomingForm()
  form.parse req, (error, fields, files) ->
    unless files.symfile?.name?
      return callback new Error('Invalid symfile upload')

    fs.readFile(files.symfile.path, encoding: 'utf8')
      .then (contents) ->
        header = contents.split('\n')[0].split(/\s+/)

        [dec, os, arch, code, name] = header

        if dec != 'MODULE'
          throw new Error 'Could not parse header (expecting MODULE as first line)'

        Symfile.create({ os: os, arch: arch, code: code, name: name , contents: contents})
          .then (symfile) ->
            callback(null, symfile)

      .catch (err) ->
        callback err

module.exports = Symfile
