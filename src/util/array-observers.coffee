
# patch Array to listen for updates
methods = ['push', 'pop', 'shift', 'unshift', 'splice', 'sort', 'reverse']
for method in methods
  do (method) ->
    _fn = Array.prototype[method]
    Array.prototype[method] = (args...) ->
      result = _fn.apply(this, arguments)
      this._observer? {
        method: method
        args: args
      }
      return result
