path = require 'path'
minidump = require 'minidump'

module.exports.getStackTraceFromRecord = (record, callback) ->
  symbolPaths = [path.join 'pool', 'symbols', record.product, record.version, "#{record.product}.breakpad.syms"]
  minidump.walkStack(record.path, symbolPaths, callback)
