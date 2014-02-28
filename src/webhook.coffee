class WebHook
  constructor: ->

  onRequest: (req, callback) ->
    data = ''
    req.on 'data', (chunk) -> data += chunk
    req.on 'error', callback
    req.on 'end', =>
      try
        event = req.headers['x-github-event']
        payload = @parsePayload data
        console.log payload
      catch e
        error = e
      callback error

  parsePayload: (data) ->
    JSON.parse data

module.exports = WebHook
