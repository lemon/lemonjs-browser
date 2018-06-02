
###
# Function for scrolling the window to a specific element
###

lemon.scrollTo = (el, duration = 800, offset = 20) ->

  y = window.scrollY
  diff = el.getBoundingClientRect().top - offset
  start = null

  step = (timestamp) ->
    start ?= timestamp
    time = timestamp - start
    percent = Math.min(time / duration, 1)
    if percent < .5
      percent = 4 * Math.pow percent, 3
    else
      percent = (percent-1)*(2*percent-2)*(2*percent-2)+1
    window.scrollTo 0, y + diff * percent
    if time < duration
      window.requestAnimationFrame step

  window.requestAnimationFrame step
