
###
# Function to check a given set of routes and return
# the first one that matches the current url, if any.
#
# The result contains the page details: hash, href, params, pathname, query
# As well as the pattern of the route that was matched, and the action to take
###

lemon.checkRoutes = (routes) ->
  for pattern, action of routes
    result = lemon.checkRoute pattern
    if result
      result.action = action
      result.pattern = pattern
      return result
  return null
