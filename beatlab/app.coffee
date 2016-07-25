class BeatLab.App extends App
  {express, mongoose, fs} = Requires

  @init: (opts={}) ->
    @site = new BeatLab.App _.extend {
      app: express()
      mongoose: mongoose
      beats_data: beats_data
      config:
        port: 3054
        title: "Kids on the beat, beat kids | BeatLab"
        base_url: 'http://beatlab.io'
        meta_keywords: ''
        meta_description: ''
        css_version: (new Date()).getTime()
        js_version: (new Date()).getTime()
      , opts
    }

  ready: ->

  setup_routes: ->
    @route "/", "home#index"
    @route "/sitemap", "sitemap#index"

  always_configure: ->
    express = express
    oneYear = 31557600000
    @app.set 'port', process.env.PORT or @conf("port")
    @app.set 'views', __dirname + '/views'
    @app.set 'view engine', 'jade'
    # @app.use express.favicon(__dirname + '/public/favicon.ico')
    @app.use express.logger('dev')
    @app.use express.cookieParser()
    @app.use express.bodyParser()
    @app.use express.session(secret: 'whateverb34tlabb3r')
    @app.use express.methodOverride()
    @app.use express.static("#{__dirname}/public", maxAge: oneYear)
    @app.use @app.router

  configure_for_development: ->
    @app.use express.errorHandler()
    @app.locals.pretty = true

  configure_for_production: ->

  before_ready: ->

