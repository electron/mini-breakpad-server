minidump = require 'minidump'

module.exports.getStackTraceFromRecord = (record, callback) ->
  minidump.walkStack(record.path, callback)
