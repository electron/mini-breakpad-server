Sequelize = require 'sequelize'
nconf = require 'nconf'

options = nconf.get 'database'

sequelize = new Sequelize(options.uri, options.username, options.password, options)

module.exports = sequelize
