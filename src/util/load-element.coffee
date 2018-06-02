
###
# Function to load a component from a dom element
# Any dom element containing the lemon-component attribute
# can be used. This function will load the component spec
# then create the component using lemon-data and lemon-contents
# as input parameters.
# component loader
###

lemon.loadElement = (el, opt) ->
  return if el._component

  # read attributes
  lcomp = el.getAttribute 'lemon-component'
  ldata = el.getAttribute 'lemon-data'
  lcontents = el.getAttribute 'lemon-contents'

  # find spec
  spec = lemon.Specs[lcomp]
  return console.warn "#{lcomp} is not a defined component" if not spec

  # copy spec to prevent multiple components modifying the same data
  spec = lemon.copy spec

  # set the target element
  spec.el = el

  # load data and contents
  data = lemoncup._data[ldata]
  contents = lemoncup._data[lcontents]

  # create and mount component
  component = new lemon.Component spec, data, contents
  component.mount opt
  el._component = component

  # done
  return component
