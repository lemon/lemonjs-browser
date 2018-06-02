
###
# Function to check whether a routing pattern matches
# the current url of the page
#
# The result contains the page details: hash, href, params, pathname, query
###

# inspired by:
# https://github.com/cowboy/javascript-route-matcher/blob/master/lib/routematcher.js

# check if the current url matches the given route
lemon.checkRoute = (pattern) ->

  # get current url
  {href, hash, pathname, search} = location

  # cleanup input
  search = search.replace '?', ''
  hash = hash.replace '#', ''
  pathname = pathname.replace /.\/$/, ''          # trim trailing slash
  pattern = pattern.replace /\*$/, '*rest'        # name ending splat
  pattern = pattern.replace /\/$/, ''             # trim trailing slash
  pattern = "/#{pattern}" if pattern[0] isnt '/'  # always start with /

  # regular expressions
  re_exp_param = /\/\((.*?)\)(\/|\b)/g            # /(a|b)
  re_named_exp_param = /\/\((.*?)\):(\w+)/g       # /(a|b):name
  re_named_param = /\/[:](\w+)/g                  # /:name
  re_splat_param = /\/[*](\w+)/g                  # /*name or *
  re_escape = /[{}?.,\\\^$#\s]/g

  # Matched param or splat names, in order
  names = []

  # build a regular expression from the pattern string
  re = pattern
  re = re.replace re_escape, "\\$&"
  re = re.replace re_exp_param, (_, exp, char) ->
    return "/(?:#{exp})#{char or ''}"
  re = re.replace re_named_exp_param, (_, exp, name) ->
    names.push name
    return "/(#{exp})"
  re = re.replace re_named_param, (_, name) ->
    names.push name
    return '/([^/]*)'
  re = re.replace re_splat_param, (_, name) ->
    names.push name
    return '/?(.*)'
  re = new RegExp "^#{re}$"

  # If no matches, return null
  matches = re.exec pathname
  return null if not matches

  # Add all named/splat values into the params object
  params = {}
  for i in [0...names.length]
    key = names[i]
    val = matches[i + 1]
    params[key] = val

  # parse query paramters
  query = {}
  for x in search.split '&'
    [k, v] = x.split '='
    query[k] = v if v?

  # return
  return {pathname, params, query, hash, href, search}
