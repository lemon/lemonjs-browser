lemon.define = (key) ->
  [pkg, name] = key.split '.'
  window[pkg] ?= {}
  window[pkg][name] = (data, contents) ->
    spec = lemon.Specs["#{pkg}.#{name}"]
    if this instanceof window[pkg][name]
      new lemon.Component spec, data, contents
    else
      lemon.Component spec, data, contents
