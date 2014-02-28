fs   = require 'fs'
path = require 'path'
temp = require 'temp'
os   = require 'os'
DecompressZip = require 'decompress-zip'
GitHub        = require 'github-releases'

temp.track()

class WebHook
  constructor: ->

  onRequest: (req) ->
    event = req.headers['x-github-event']
    payload = req.body

    return unless event is 'release' and payload.action is 'published'
    @downloadAssets payload

  downloadAssets: (payload) ->
    github = new GitHub
      repo: payload.repository.full_name
      token: process.env.MINI_BREAKPAD_SERVER_TOKEN

    dir = temp.mkdirSync()

    for asset in payload.release.assets when /sym/.test asset.name
      do (asset) =>
        filename = path.join dir, asset.name
        github.downloadAsset asset, (error, stream) =>
          if error?
            console.log 'Failed to download', asset.name, error
            return
          file = fs.createWriteStream filename
          stream.on 'end', @extractFile.bind(this, filename)
          stream.pipe file

  extractFile: (filename) ->
    console.log 'extracting', filename

module.exports = WebHook
