Sequelize = require 'sequelize'
sequelize = require './db'

Symbols = sequelize.define('symbols', {
  id:
    type: Sequelize.INTEGER
    autoIncrement: yes
    primaryKey: yes
  os: Sequelize.STRING
  code: Sequelize.STRING
  arch: Sequelize.STRING
  filename: Sequelize.STRING
})

Symbols.sync()

Symbols.createFromRequest = (req, callback) ->
  console.log('todo')

model.exports = Symbols
