
# listen for window events
( ->
  for name in ['resize', 'scroll']
    do (name) ->
      _running = false
      _event = e
      window.addEventListener name, (e) ->
        _event = e
        if not _running
          _running = true
          window.requestAnimationFrame ->
            lemon.emit name, _event
            _running = false
)()
