path = require 'path'
minidump = require 'minidump'
cache = require './cache'

module.exports.getStackTraceFromRecord = (record, callback) ->
  return callback(null, cache.get(record.id)) if cache.has record.id

  symbolPaths = [ path.join 'pool', 'symbols' ]
  minidump.walkStack record.path, symbolPaths, (err, report) ->
    cache.set record.id, report unless err?
    callback err, report
