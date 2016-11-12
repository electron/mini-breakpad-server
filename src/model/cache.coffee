cache = {}

module.exports =
  get: (id) -> cache[id]
  set: (id, data) -> cache[id] = data
  has: (id) -> cache.hasOwnProperty id
