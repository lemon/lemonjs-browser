
###
# load all top-level components
###
lemon.init = ->
  _render = page.data?._render or false

  # update current page data
  lemon.updatePageData()

  # define lemon specs
  lemon.define key for key of lemon.Specs

  # load component on document to start
  component = new lemon.Component {
    id: 'document'
    el: document
  }
  component._hydrate document, {
    render: _render
  }
