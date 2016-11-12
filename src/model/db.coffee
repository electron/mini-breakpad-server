Sequelize = require 'sequelize'

sequelize = new Sequelize('database', 'username', 'password', {
  host: 'localhost'
  dialect: 'sqlite'
  storage: 'database.sqlite'
})

module.exports = sequelize
