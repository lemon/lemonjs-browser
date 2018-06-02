
###
# Function for computing the true scrolling height of the body
###

lemon.bodyHeight = ->
  body = document.body
  html = document.documentElement
  height = Math.max [
    body.scrollHeight
    body.offsetHeight
    html.clientHeight
    html.scrollHeight
    html.offsetHeight
  ]...
  return height
