Sequelize = require 'sequelize'
sequelize = require './db'
formidable = require 'formidable'

DIST_DIR = 'pool/symbols'

Symfile = sequelize.define('symfiles', {
  id:
    type: Sequelize.INTEGER
    autoIncrement: yes
    primaryKey: yes
  os: Sequelize.STRING
  code: Sequelize.STRING
  arch: Sequelize.STRING
  filename: Sequelize.STRING
})

Symfile.sync()

Symfile.createFromRequest = (req, callback) ->
  console.log('todo')

Symfile.saveToDisk = (symfile, callback) ->
  console.log('todo')

model.exports = Symfile
