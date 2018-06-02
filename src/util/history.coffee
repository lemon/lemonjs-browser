
# if browser has pushState, listen for changes
if history?.pushState
  for method in ['pushState', 'replaceState']
    do (method) ->
      _function = history[method]
      history[method] = ->
        result = _function.apply history, arguments
        lemon.updatePageData()
        lemon.emit "url_change", page
        return result

  # popstate for back/forward/go
  window.addEventListener 'popstate', (e) ->
    lemon.updatePageData()
    lemon.emit "url_change", page
