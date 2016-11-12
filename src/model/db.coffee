Sequelize = require 'sequelize'

sequelize = new Sequelize('database', 'username', 'password', {
  host: 'localhost'
  dialect: 'sqlite'
  storage: 'database.sqlite'
  logging: no
})

module.exports = sequelize
