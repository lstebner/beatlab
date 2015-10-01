class App.Router
  @debug: false
  constructor: (@app, @opts={}) ->
    if !@app
      throw new Error("an app is required to create a Router")
    @routes = []

  register: (type, path, controller, method) ->
    console.log "router: add_route #{type.toUpperCase()} #{path}, #{controller.name}##{method}" if Router.debug
    new_route = [type, path, controller, method]
    @routes.push new_route
    @app[type] path, (req, res) =>
      c = new controller(req, res)
      if !c.do method
        console.error "method '#{method}' not found for controller #{controller}"
        @do_404(res)

    new_route

  do_404: (res) -> res.status(404).send "Sorry, page not found!"

  get: (path, controller, method) ->
    @register 'get', path, controller, method

  post: (path, controller, method) ->
    @register 'post', path, controller, method

  #add in bulk!
  # i'm not sure if this method is or should be used anymore
  add_routes: (controller) ->
    for path, route of controller.routes
      data =
        type: "get"
        path: path
        controller: controller
        method: null

      if _.isObject(route)
        data = _.extend data, route
      else
        data.method = route

      @register data.type, data.path, data.controller, data.method
