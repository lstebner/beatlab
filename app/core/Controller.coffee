class App.Controller
  name: "base"
  view_class: App.View

  constructor: (@req, @res) ->
    @requirements_list = {}
    @loaded_items = []
    @current_needs = []
    @public_methods = []

    @view_data = {}
    @view_to_render = ""

    @setup()

  setup: ->
    @setup_preload()

  setup_preload: -> 1

  requires: (needs_list, for_what="all") ->
    needs_list = [needs_list] unless _.isArray(needs_list)

    _register = (method_name, needs_list) =>
      @requirements_list[method_name] = if @requirements_list[method_name]?
        _.union @requirements_list[method_name], needs_list
      else
        needs_list

    if _.isObject(for_what)
      methods = if for_what.except?
        _.difference @public_methods, for_what.except
      else if for_what.only?
        _.intersection @public_methods, for_what.only

      for m in methods
        _register m, needs_list
    else if for_what == "all"
      for m in @public_methods
        _register m, needs_list
    else
      _register for_what, needs_list

  preload: (for_method) ->
    return true unless @requirements_list[for_method]?
    @current_needs = @requirements_list[for_method]
    @load @current_needs.join(" ")

  do: (@requested_method, @prevent_render=true) ->
    @preload @requested_method

    if @has_needs_met()
      if @[@requested_method]? && _.indexOf(@public_methods, @requested_method) > -1
        @[@requested_method]()
        unless @prevent_render
          @render()
        true
      else
        console.log "method not found or not public", "#{@name}::#{@requested_method}"
        @do_404()
    else
      setTimeout =>
        @do @requested_method, @prevent_render
      , 50

    true

  do_404: ->
    @res.status 404
    @res.render '404', title: ' 404, man'

  param: (key) ->
    if @req.params.hasOwnProperty(key) then @req.params[key] else false

  query: (key) ->
    if @req.query.hasOwnProperty(key) then @req.query[key] else false

  cookie: (key) ->
    if @req.cookies && @req.cookies.hasOwnProperty(key) then @req.cookies[key] else false

  body: (key) ->
    if @req.body && @req.body.hasOwnProperty(key) then @req.body[key] else false

  redirect: (dest, status=302) ->
    @res.redirect status, dest

  load: (load_items) ->
    # console.log "load requested: #{load_items}"
    if @loaded_items
      for i in @loaded_items
        load_items = load_items.replace("#{i}", "")

      load_items = _str.trim load_items.replace /\s\s/g, ""
    else
      @loaded_items = []

    return false unless load_items.length
    true

  loaded: (item_name) ->
    @loaded_items ||= []
    @loaded_items.push item_name 

  has_needs_met: ->
    return true if _.isEmpty(@current_needs)
    has_everything = true

    for need in @current_needs
      has_everything = has_everything && _.indexOf(@loaded_items, need) > -1

    has_everything

  json: (obj) ->
    @res.json obj

  render: (view_name=null, data=@view_data) ->
    if !@view_class
      # console.log("render bailing, no view class set")
      return false

    @before_render()
    if @cancel_render
      return @cancel_render = false

    @view_data.view = if !_.isEmpty(view_name)
      view_name
    else if !_.isEmpty(@view_to_render)
      @view_to_render
    else
      @requested_method

    @current_view = new @view_class @view_data, @req, @res, @app
    @current_view.render()
    @after_render()
    @cancel_render = false
    
    @current_view

  set_view: (@view_to_render) -> 1

  before_render: ->
    #override me
    1

  after_render: ->
    #override me
    1




