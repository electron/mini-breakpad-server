path = require 'path'
minidump = require 'minidump'

module.exports.getStackTraceFromRecord = (record, callback) ->
  symbolPaths = [
    path.join 'pool', 'symbols', 'Common'
    path.join 'pool', 'symbols', record.product
  ]
  minidump.walkStack(record.path, symbolPaths, callback)
