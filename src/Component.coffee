
# Component class
class lemon.Component

  # default spec properties
  _defaults: {
    class: ''
    computed: {}
    contents: null
    data: {}
    lifecycle: {}
    methods: {}
    mounted: false
    routes: {}
    template: ->
    watch: {}
  }

  constructor: (spec, data, contents) ->

    # if being called without "new", in a template, render a dom stub
    # which can be loaded after the current component is finished rendering
    if not (this instanceof lemon.Component)
      attrs = {}
      for k, v of data
        if k in ['id', 'class']
          attrs[k] = v
        if k in ['style', 'data', 'on', 'bind'] or k[0] in ['$', '_']
          attrs[k] = v
          delete data[k]
      attrs['lemon-component'] = "#{spec.package}.#{spec.name}"
      attrs['lemon-contents'] = contents if contents
      attrs['lemon-data'] = data
      tag (spec.element or 'div'), attrs
      return

    # spec
    spec = Object.assign {}, @_defaults, spec
    for k, v of spec
      @["_#{k}"] = v

    # lifecycle hook
    @_hook 'beforeCreate'

    # el, data, contents
    @_data = Object.assign {}, spec.data, data
    @_contents = contents or spec.contents or ->
    @_id ?= @_data.id
    @_class ?= @_data.class
    @_uid = @_id or @_data.id or lemon.uid()
    @_ref = @_data.ref

    # expose el
    Object.defineProperty this, 'el', {
      get: ->
        return @_el
    }

    # add to component map
    lemon.Components[@_uid] = this

    # default ref to uid
    @_ref ?= @_uid

    # dom modifications
    # add uid, ref, id, class to dom
    # is @el is document, setAttribute doesn't exist
    if @el
      @el.setAttribute? 'lemon-uid', @_uid
      @el.setAttribute? 'lemon-ref', @_ref if @_ref
      @el.setAttribute? 'id', @_id if @_id
      lemon.addClass @el, @_class if @_class

    # make methods easier to access
    @[name] ?= fn.bind this for name, fn of @_methods

    # container for child components
    @_children = []

    # container for refs
    @_refs = {}

    # event listeners
    @_listeners = []

    # add observers to watch for data changes
    @_observe key for key of @_data

    # computed fields
    for key of @_computed
      do (key) =>
        self = this

        # for use in event handlers
        Object.defineProperty self, key, {
          get: ->
            self._apply self._computed[key]
        }

        # for us in template
        Object.defineProperty @_data, key, {
          get: ->
            self._apply self._computed[key]
        }

    # lifecycle hook
    @_hook 'created'

  ###
  # PRIVATE METHODS
  ###

  # add new event listener
  _addEventListener: (el, event, handler) ->
    [el, event, handler] = [@el, el, event] if not handler
    for x in @_listeners when x[0] is el and x[1] is event
      return
    @_listeners.push [el, event, handler]
    el.addEventListener event, handler

  # call a function if it exists
  _apply: (fn, args) ->
    if typeof fn is 'string'
      if @_methods[fn]
        @_methods[fn].apply @, args
      else
        @_warn "#{fn} is not defined"
    else if typeof fn is 'function'
      fn.apply @, args
    else
      return true

  # update the dom based on property bindings
  _bind: (el, key = '', options = {}) ->
    key = "='#{key}'" if key

    rules = {
      'src': (node, value) ->
        node.setAttribute 'src', value
      'href': (node, value) ->
        node.setAttribute 'href', value
      'text': (node, value) ->
        node.textContent = "#{value}"
      'html': (node, value) ->
        node.innerHTML = "#{value}"
      'on': (node, value, options) =>
        node.innerHTML = ''
        @_bindListRule node, [value], options
      'list': @_bindListRule.bind this
    }

    for prop, fn of rules
      attr = "lemon-bind:#{prop}"
      for node in @_find el, "[#{attr.replace ':', '\\:'}#{key}]"
        value = @[node.getAttribute attr]
        fn node, value, options

  # update arrays in the dom based on property bindings
  _bindListRule: (node, items, options = {}) ->
    {method, args} = options
    temp = node.getAttribute "lemon-bind:template"
    comp = node.getAttribute "lemon-bind:component"
    fn = lemoncup._data[temp] or lemoncup._data[comp]
    data = @_data
    if temp
      template = ({fn, item, data}) ->
        div 'lemon-data': item, ->
          fn item, data
    else
      template = ({fn, item, data}) ->
        fn item, data

    switch method

      when 'pop'
        if node.lastChild
          node.removeChild node.lastChild

      when 'push', undefined
        node.innerHTML = null if not method
        for item in args or items
          el = @_render {
            data: {fn, item, data}
            el: node
            method: 'append'
            template: template
          }
          @_hydrate el

      when 'reverse'
        for el in node.children
          node.insertBefore el, node.firstChild

      when 'shift'
        if node.firstChild
          node.removeChild node.firstChild

      when 'sort'
        fn = args[0] or (a, b) -> if a < b then -1 else 1
        children = (child for child in node.children)
        children = children.sort (a, b) ->
          value_a = lemoncup._data[a.getAttribute 'lemon-data']
          value_b = lemoncup._data[b.getAttribute 'lemon-data']
          return fn value_a, value_b
        for child in children
          node.appendChild child

      when 'splice'
        if args[0] is 0 and args.length is 1
          node.innerHTML = ''
        else
          @_warn "splice not supported"

      when 'unshift'
        for item in args.reverse()
          el = @_render {
            data: {fn, item, data}
            el: node
            method: 'prepend'
            template: template
          }
          @_hydrate el

  # destroy this component
  _destroy: ->

    # lifecycle hook
    @_hook 'beforeDestroy'

    # cleanup router
    lemon.off 'url_change', @_onUrlChange

    # remove listeners
    @_removeEventListeners()

    # destroy children
    for child in @_children
      child._destroy()

    # delete from component map
    delete lemon.Components[@_uid]

    # remove the element
    @el.parentNode?.removeChild @el

    # lifecycle hook
    @_hook 'destroyed'

  # find elements in my component, but not in child components
  _find: (target, selector) ->
    [target, selector] = [@el, target] if typeof target is 'string'

    elements = target.querySelectorAll selector
    mine = []
    for el in elements
      is_mine = true
      parent = el.parentNode
      while parent isnt target
        if parent.getAttribute 'lemon-component'
          is_mine = false
          break
        parent = parent.parentNode
      mine.push el if is_mine
    return mine

  # call a lifecycle hook
  _hook: (name) ->
    @_apply @_lifecycle[name]

  # hydrate a dom element
  _hydrate: (el, opt={}) ->
    el ?= @el

    # event listeners
    for event in lemon.browser_events
      key = "lemon-on:#{event}"
      nodes = @_find el, "[#{key.replace ':', '\\:'}]"
      for node in nodes
        do (node, event, key) =>
          @addEventListener node, event, (e) =>
            value = node.getAttribute key
            fn = lemoncup._data[value] or @[value]
            @_apply fn, [e]

    # child components
    for node in @_find el, "[lemon-component]"
      component = lemon.loadElement node, opt
      component._parent = this
      if component
        @_children.push component

    # find references
    for node in @_find el, "[lemon-ref]"
      ref = node.getAttribute 'lemon-ref'
      uid = node.getAttribute 'lemon-uid'
      @_refs[ref] = if uid then lemon.get(uid) else node
      @[ref] = @_refs[ref]

    # property binding
    @_bind el, null, opt

    # intercept internal links
    links = @_find el, "a[href^='/'],a[href^='?'],a[href^='#']"
    for link in links
      do (link) =>
        @addEventListener link, 'click', (e) =>
          e.preventDefault()
          lemon.route link.getAttribute('href')

  # mount component
  _mount: (opt={}) ->

    # defaults
    opt.render ?= true
    opt.render = true if @el.innerHTML is ''

    # lifecycle hook
    @_hook 'beforeMount'

    # remove listeners
    @_removeEventListeners()

    # write to the dom
    # render option allows us to render server-side and not re-render in the
    # browser. some elements may not have been rendered server-side, so if
    # innerHtml is empty, force a render
    if opt.render
      @_render {
        el: @el
        template: @_template
        data: @_data
        contents: @_contents
      }

    # hydrate result
    @_hydrate @el, opt

    # lifecycle hook
    @_hook 'mounted'

    # routing
    @_startRouter()

    # set mounted property
    @_mounted = true

  # add listeners for data property changes
  _observe: (key) ->
    Object.defineProperty this, key, {
      get: ->
        return @_data[key]
      set: (value) ->
        return if @_data[key] is value
        @_data[key] = value
        @_apply @_watch[key], [value]
        @_bind @el, key
        if Array.isArray value
          @_observeArray key
    }
    if Array.isArray @_data[key]
      @_observeArray key

  # add listeners for data property changes (for arrays)
  _observeArray: (key) ->
    return if @_data[key]._observer
    self = this
    Object.defineProperty @_data[key], '_observer', {
      enumerable: false
      value: ({method, args}) ->
        self._bind self.el, key, {method, args}
   }

  # remove all event listeners
  _removeEventListeners: ->
    for listener in @_listeners
      [el, name, handler] = listener
      el.removeEventListener name, handler
    @_listeners = []

  # render the template to the dom
  _render: (options) ->
    {el, method, template, data, contents} = options

    # render html
    html = lemoncup.render template, data, contents

    # update dom
    return lemon.updateDOMElement el, method, html

  # start this component's router
  _startRouter: ->
    return if @_onUrlChange
    return if (k for k of @_routes).length is 0

    # define url_change handler
    onUrlChange = ->
      match = lemon.checkRoutes @_routes
      if match
        @_apply match.action, [match]

    # bind context and add listener
    @_onUrlChange = onUrlChange.bind this
    lemon.on 'url_change', @_onUrlChange
    @_onUrlChange()

  # warning log
  _warn: ->
    console.warn "[#{@_package}.#{@_name}]", arguments...

  ###
  # PUBLIC METHODS
  ###

  addEventListener: -> @_addEventListener arguments...
  find: -> @_find arguments...
  findOne: -> @_find(arguments...)[0]
  hydrate: -> @_hydrate arguments...
  mount: -> @_mount arguments...
  render: -> @_render arguments...
  warn: -> @_warn arguments...

