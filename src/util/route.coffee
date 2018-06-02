
###
# Function for programmatic page changes.
###

# lemon.route
lemon.route = (url) ->
  {pathname, href} = location
  return if url in [pathname, href]
  if history.pushState
    history.pushState null, null, url
  else
    document.location = url
  return false
