class World.Widget
  @init: (id, opts={}) ->
    @_instances ||= []
    @_instances.push new @ id, opts

  constructor: (container, @opts={}) ->
    @container = $ container
    @key_bindings = []
    @global_key_bindings = []
    @setup()

  trigger: (evnt, args...) ->
    @container.trigger evnt, args...

  on: (evnt, fn) ->
    if !@container.length
      return console.error "event attached to widget with no container"
    @container.on evnt, fn

  before_setup: -> 1

  ready: -> 1

  setup_events: -> 1

  dispatch: (evnt, map) ->
    @on evnt, (e) =>
      $el = $ e.target
      for key, fn of map
        if $el.is(key) || $el.hasClass("#{key}")
          prevent = fn.apply @, [$el, e]
          e.preventDefault() if prevent

  setup: ->
    @should_render = false

    @before_setup()

    @setup_events()
    @setup_key_handlers()

    @ready()
    @render()

  bind_key: (key, fn, global=false) ->
    if !_.isArray(key)
      key = [key]

    if global
      @global_key_bindings.push [key, fn]
    else
      @key_bindings.push [key, fn]

  setup_key_handlers: ->
    fire_key_event = (keycode, bindings, e) =>
      for binding in bindings
        if _.indexOf(binding[0], keycode) > -1
          return binding[1].call @, e

      false

    if !_.isEmpty(@key_bindings)
      @container.on "keydown", (e) =>
        prevent = fire_key_event e.keyCode, @key_bindings, e
        console.log "prevent", prevent
        e.preventDefault() if prevent

    if !_.isEmpty(@global_key_bindings)
      $(document.body).on "keydown", (e) =>
        prevent = fire_key_event e.keyCode, @global_key_bindings, e
        e.preventDefault() if prevent

  render: ->
    return unless @should_render

    @should_render = false
    true
