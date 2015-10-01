class App
  {fs, express} = Requires

  CONF_DEFAULTS =
    title: ""
    base_url: ''
    meta_keywords: ''
    meta_description: ''
    css_version: 1
    js_version: 1
    port: 3000
    debug: false

  ROOT_DIR = __dirname.replace(/spec(\/|)/, "")

  @set_site: (@site) ->

  # call to init your app by passing your custom app class second
  @init: (opts={}, appclass=App) ->
    if appclass == App
      @site = new App opts
    else
      @site = appclass["init"] opts

  @slugify: (title, d) ->
    replace = "-"
    str = title.toString().replace(/[\s\.]+/g, replace).toLowerCase().replace(new RegExp("[^a-z0-9" + replace + "]", "g"), replace).replace(new RegExp(replace + "+", "g"), replace)
    str = str.substring(0, str.length - 1)  if str.charAt(str.length - 1) is replace
    str = str.substring(1)  if str.charAt(0) is replace
    if d?
      str + "-" + d.getDate() + "-" + (d.getMonth() + 1) + "-" + d.getFullYear()
    else
      str

  @pretty_date: (date) ->
    moment(date).fromNow()

  #be aware, quiet failures can happen
  @base_url: (uri, force_full=false) ->
    @site?.base_url uri, force_full

  @conf: (key) ->
    @site?.conf key

  @get_conf: ->
    @site?.config

  constructor: (opts={}) ->
    @env = process.env.NODE_ENV
    {@site_name, @config, @app, @mongoose} = opts

    @config = _.extend CONF_DEFAULTS, (@config || {})

    @load_environment_config()
    @setup()

  load_environment_config: ->
    filepath = "#{ROOT_DIR}/app/conf/#{@env}.conf"

    contents = fs.readFileSync filepath, "UTF-8"
    try
      env_conf = JSON.parse contents
      @config = _.extend @config, env_conf
      console.log "#{@env} config loaded" if @config.debug
    catch e
      console.log "error! parsing json in #{@env} conf" if @config.debug

  before_ready: -> 1

  setup: ->
    for key, val of Requires
      @[key] = val
      
    @configure_app()
    @router = new App.Router @app

    @setup_mongoose()
    @setup_routes()

    @listener = @app.listen @config.port
    if @listener
      console.log "Express server listening on port %d in %s mode", @listener.address().port, @app.settings.env if @config.debug
    else
      console.log "listener did not start" if @config.debug

    @before_ready()

    @is_setup = true
    @ready()

  # override if you want
  ready: -> 1

  setup_mongoose: ->
    @mongoose.connect "mongodb://#{@conf 'db_host'}/#{@conf 'db_name'}"

  conf: (key) ->
    if key? && @config?.hasOwnProperty(key) then @config[key] else false

  base_url: (uri="/", force_full=false) ->
    return uri if process.env.NODE_ENV == 'development' && !force_full
    url = "#{@conf 'base_url' }#{uri}"

  route: (uri, dest, type="get") ->
    default_method = "index"
    dest_wedge = "#"
    dest_sp = dest.split dest_wedge

    controller_name = dest_sp[0].substr(0, 1).toUpperCase() + dest_sp[0].substring(1)
    controller = App["#{controller_name}Controller"]
    return (if @config.debug then console.log "App route error, controller not found: #{controller_name}" else false) unless controller?

    method_name = if dest_sp[1]? then dest_sp[1] else default_method

    switch (type)
      when "get" then @router.get uri, controller, method_name
      when "post" then @router.post uri, controller, method_name

  #meant to be overidden for app instance
  setup_routes: ->
    @route "/sitemap", "sitemap" 
    @route "/post/:slug", "post#index"
    @route "/category/:category", "listing#by_category"
    @route "/tag/:tag", "listing#by_tag"
    @route "/blog", "listing#latest" 
    @route "/store", "store" 
    @route "/about-me", "home#about"
    @route "/", "home" 

  configure_app: ->
    express = express
    @app.configure => @always_configure()

    @app.configure "development", =>
      @app.use express.errorHandler(
        dumpExceptions: true
        showStack: true
      )

      @configure_for_development()

    @app.configure "production", =>
      @app.use express.errorHandler()
      @configure_for_production()

    # TODO: state machine
    @is_configured = true

  always_configure: ->
    #override me for setup actions
    @app.set "views", ROOT_DIR + "/views"
    @app.set "view engine", "jade"
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    @app.use @app.router
    @app.use express.static(ROOT_DIR + "/public")

  configure_for_development: ->
    #override me specifically for development
    1

  configure_for_production: ->
    #override me specifically for production
    1







