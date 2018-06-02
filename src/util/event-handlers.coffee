
# global event handler storage
lemon.events = {}

# Function to emit a global event
lemon.emit = (event, args...) ->
  for handler in lemon.events[event] or []
    handler args...

# Function to add a listener for a global event
lemon.on = (event, handler) ->
  lemon.events[event] ?= []
  lemon.events[event].push handler

# Function to add a one-time listener for a global event
lemon.once = (event, handler) ->
  lemon.events[event] ?= []
  wrapper = (args...) =>
    lemon.off event, wrapper
    handler args...
  lemon.events[event].push wrapper

# Function to remove a listener for a global event
lemon.off = (event, handler=null) ->
  lemon.events[event] ?= []
  lemon.events[event] = lemon.events[event].filter (fn) ->
    handler isnt null and fn isnt handler
