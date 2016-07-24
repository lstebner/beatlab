# @codekit-prepend "app/core/_main"
# @codekit-append "app/views/__index"
# @codekit-append "app/controllers/__index"

HUSH_LOG = false
__log = (args...) ->
  console.log(args...) unless HUSH_LOG 

fs = require("fs")
beats_data_raw = fs.readFileSync("./beats_data.txt", "UTF-8").trim()

class BeatsData
  constructor: (@file_contents, config={}) ->
    @setup_config config
    @process() if @file_contents?

  setup_config: (config={}) ->
    defaults =
      use_s3: true
      s3_path: "https://s3-us-west-1.amazonaws.com/beatlabio/"
      # if not using s3 otherwise s3_path takes precedence
      beat_root_path: "/beats/"

    @config = _.extend defaults, config

  get_blocks: (type=null) ->
    if type?
      found = []
      for block in @blocks
        if block.type == type
          found.push block

      found
    else
      @blocks

  process: ->
    __log "BeatsData: beginning process"
    @blocks = []
    @_all_beats = []
    @processing_block = 0
    @_data_keys = {}
    found_start = false
    first_starting_line = false
    starting_line = "---"

    for line in @file_contents.split("\n")
      # the very first line contains the ordered keys each beat will be listed in
      if first_starting_line
        __log "BeatsData: store_data_keys #{line}"
        @store_data_keys line
        first_starting_line = false
      # everything above the `starting_line` is thrown out
      else if !found_start && line.trim() == starting_line
        __log "BeatsData: found start"
        found_start = true
        first_starting_line = true
      # standard line processing
      else if found_start
        @process_line line

    @_all_beats

  process_line: (line) ->
    line = line.trim()
    return unless line.length
    __log "BeatsData: process line #{line}"

    # start of collection block
    if line.match(/^collection do/)?
      @start_block "collection", line.substr(line.indexOf(" do ") + 4)
    # end of some block
    else if line == "end"
      @end_block()
    # generic line (empty already filtered out, probably a beat)
    else
      @store_beat line

  store_data_keys: (line) ->
    @_data_keys = []
    for k in line.split(",")
      @_data_keys.push k.trim()

  default_beat_data_clone: ->
    return @_beat_data_defaults if @_defaults

    _defaults =
      file_path: ""
      title: ""
      collection: ""
      version: 0
      created_on: null
      updated_on: null
      tags: []

    for key in @_data_keys
      unless _defaults[key]?
        _defaults[key] = ""

    @_beat_data_defaults = _defaults

  start_block: (type, line) ->
    __log "start block #{type} -- #{line}"
    @processing_block = type
    @this_block_meta = name: "", dir: "", hide: false, type: type
    parts = line.split(",")

    for p in parts
      pair = p.split(":")
      if pair.length > 1
        key = pair[0].trim()

        @this_block_meta[key] = pair[1].trim()

  end_block: ->
    switch @processing_block
      when 'collection' then 1

    @blocks.push _.clone @this_block_meta

    @processing_block = 0

  store_beat: (line) ->
    line = line.trim()
    beat_data = @default_beat_data_clone()
    matched_lists = line.match(/\[([a-zA-Z,\s]+)\]/)
    data_keys = if @processing_block == "collection"
      _.without @_data_keys, "collection" 

    if matched_lists?
      for match, i in matched_lists
        matches = match.replace(/[\[|\]]/g, "").split(",")
        matched_lists[i] = []
        for m in matches
          matched_lists[i].push m.trim()

        line = line.replace(match, "__mlist#{i}")

    for piece, i in line.split(",")
      piece = piece.trim()
      # handle special pieces
      if piece.match(/__mlist/)?
        idx = parseInt(piece.replace("__mlist", ""))
        if matched_lists[idx]?
          piece = matched_lists[idx]

      beat_data[data_keys[i]] = piece

    # generated properties
    beat_data.source = if @config.use_s3
      "#{@config.s3_path}#{beat_data.file_path}"
    else
      "#{@config.beat_root_path}#{beat_data.file_path}"

    beat_data.type = beat_data.file_path.substr(beat_data.file_path.lastIndexOf(".") + 1)

    if @processing_block == "collection"
      beat_data.collection = @this_block_meta.name

    @_all_beats.push beat_data

beats_data = new BeatsData beats_data_raw


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


class BeatLab.Query
  get_beats: (q={}) ->
    if q.tags
      @get_beats_tagged q.tags
    else
      @get_all_beats()
  
  get_all_beats: ->
    beats_data._all_beats

  get_beats_tagged: (tags=[]) ->
    if typeof tags == "string"
      tags = [tags]

    found = []

    for beat in beats_data._all_beats
      this_matched = false
      for t in tags
        if !this_matched && beat.tags.indexOf(t)
          this_matched = true
          found.push beat

    found

  get_beats_in_collection: (collection) ->
    found = []
    collections = beats_data.get_blocks("collection")
    coll = null 

    for c in collections
      if c.name == collection
        coll = _.clone c

    unless coll?
      console.log "error finding collection '#{collection}' in #{JSON.stringify collections}"
      return [] 

    for beat in beats_data._all_beats
      if beat.collection == collection
        found.push beat

    coll.beats = found
    coll

class BeatLab.Controller extends App.Controller

