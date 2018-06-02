
###
# Function to deep copy an object
###

lemon.copy = (obj) ->
  return obj if obj is null or typeof obj isnt 'object'

  # dates
  if obj instanceof Date
    return new Date obj.getTime()

  # regular expressions
  if obj instanceof RegExp
    return new RegExp obj

  # keep dom elements
  if obj.nodeType
    return obj

  # arrays
  if Array.isArray obj
    copy = []
    for val in obj
      copy.push lemon.copy val
    return copy

  # objects
  if obj instanceof Object
    copy = {}
    for key, val of obj
      copy[key] = lemon.copy val
    return copy

  return null
