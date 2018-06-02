
###
# List of browser methods available in the current browser
# for adding event listeners on
###

# load browser events
lemon.browser_events = []
for e of document
  if (typeof document[e] isnt "function" and e?.substring(0, 2) is "on")
    lemon.browser_events[lemon.browser_events.length] = e.replace 'on', ''
