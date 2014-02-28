fs     = require 'fs-plus'
glob   = require 'glob'
mkdirp = require 'mkdirp'
path   = require 'path'
temp   = require 'temp'
os     = require 'os'
wrench = require 'wrench'
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

    for asset in payload.release.assets when /sym/.test asset.name
      do (asset) =>
        dir = temp.mkdirSync()
        filename = path.join dir, asset.name
        github.downloadAsset asset, (error, stream) =>
          if error?
            console.log 'Failed to download', asset.name, error
            @cleanup dir
            return
          file = fs.createWriteStream filename
          stream.on 'end', @extractFile.bind(this, dir, filename)
          stream.pipe file

  extractFile: (dir, filename) ->
    targetDirectory = "#{filename}-unzipped"
    unzipper = new DecompressZip filename
    unzipper.on 'error', (error) =>
      console.log 'Failed to decompress', filename, error
      @cleanup dir
    unzipper.on 'extract', =>
      fs.closeSync unzipper.fd
      fs.unlinkSync filename
      @copySymbolFiles dir, targetDirectory
    unzipper.extract path: targetDirectory

  copySymbolFiles: (dir, targetDirectory) ->
    glob '*.breakpad.syms', cwd: targetDirectory, (error, dirs) =>
      if error?
        console.log 'Failed to find breakpad symbols in', targetDirectory, error
        @cleanup dir
        return

      symbolsDirectory = path.join 'pool', 'symbols'
      for symbol in dirs
        fs.copySync path.join(targetDirectory, symbol), symbolsDirectory
      @cleanup dir

  cleanup: (dir) ->
    wrench.rmdirSyncRecursive dir, true

module.exports = WebHook
