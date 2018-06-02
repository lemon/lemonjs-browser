
###
# Function to find a dom elements location in the browser/window
# Includes standard getBoundingClientRect() properties, as well
# as _top and _bottom which specify the elements distance to the
# top and bottom of the current viewport.
###

lemon.offset = (el) ->
  rect = el.getBoundingClientRect()
  rect._top = Math.max 0, rect.top
  rect._bottom = Math.max 0, window.innerHeight - rect.top - rect.height
  return rect
