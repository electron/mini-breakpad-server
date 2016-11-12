Sequelize = require 'sequelize'
sequelize = require './db'
formidable = require 'formidable'
fs = require 'fs-promise'

DIST_DIR = 'pool/symbols'
COMPOSITE_INDEX = 'compositeIndex'

Symfile = sequelize.define('symfiles', {
  id:
    type: Sequelize.INTEGER
    autoIncrement: yes
    primaryKey: yes
  os:
    type: Sequelize.STRING
    unique: COMPOSITE_INDEX
  name:
    type: Sequelize.STRING
    unique: COMPOSITE_INDEX
  code:
    type: Sequelize.STRING
    unique: COMPOSITE_INDEX
  arch:
    type: Sequelize.STRING
    unique: COMPOSITE_INDEX
  contents: Sequelize.TEXT
})

Symfile.sync()

Symfile.saveToDisk = (symfile) ->
  symfileDir = "#{DIST_DIR}/#{symfile.name}/#{symfile.code}"
  fs.mkdirs(symfileDir).then ->
    fs.writeFile("#{symfileDir}/#{symfile.name}.sym", symfile.contents)

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

        props =
          os: os
          arch: arch
          code: code
          name: name
          contents: contents

        sequelize.transaction (t) ->
          whereDuplicated =
            where: { os: os, arch: arch, code: code, name: name}

          Symfile.findOne(whereDuplicated, {transaction: t}).then (duplicate) ->
            p =
              if duplicate?
                duplicate.destroy({transaction: t})
              else
                Promise.resolve()
            p.then ->
              Symfile.create(props, {transaction: t}).then (symfile) ->
                Symfile.saveToDisk(symfile).then ->
                  callback(null, symfile)

      .catch (err) ->
        callback err

module.exports = Symfile
