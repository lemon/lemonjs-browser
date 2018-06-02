
###
# lemon
###

lemon.ajax = (options, next) ->
  {data, headers, method, qs, timeout, url} = options

  # defaults
  method ?= 'GET'
  headers ?= {}

  # if typeof data is object, set content-type header
  if typeof data is 'object'
    headers['Content-Type'] = 'application/json'
    data = JSON.stringify data

  # create request
  req = new XMLHttpRequest()

  # check for query string
  if qs
    url += "?" + (encodeURI "#{k}=#{v}" for k, v of qs).join '&'

  # check for timeout
  if timeout
    req.timeout = timeout
    req.ontimeout = (e) -> next e

  # open request
  req.open method, url

  # set headers
  for k, v of headers
    req.setRequestHeader k, v

  # listen for request status
  req.onreadystatechange = ->
    if req.readyState is 4 and (req.status >= 200 and req.status < 400)
      body = req.responseText
      content_type = req.getResponseHeader 'Content-Type'
      if content_type?.match /json/
        body = JSON.parse body
      next null, body
    else if req.readyState is 4
      next {status: req.status, error: req.statusText}

  # connection error
  req.onerror = (err) ->
    next err

  # send request
  req.send data
