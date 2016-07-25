class BeatsData
  constructor: (@file_contents="", config={}) ->
    @setup_config config
    @process() if @file_contents?

  setup_config: (config={}) ->
    defaults =
      use_s3: true
      s3_path: "https://s3-us-west-1.amazonaws.com/beatlabio/"
      # if not using s3 otherwise s3_path takes precedence
      beat_root_path: "/beats/"

    @_config = _.extend defaults, config

  config: (key, val=undefined) ->
    if key && val != undefined
      @_config[key] = val

    @_config[key]

  get_blocks: (type=null) ->
    if type?
      found = []
      for block in @blocks
        if block.type == type
          found.push block

      found
    else
      @blocks

  get_beat_from_ref: (ref) ->
    if @_beat_refs[ref]
      @_all_beats[@_beat_refs[ref]]
    else
      false

  process: ->
    __log "BeatsData: beginning process"
    @blocks = []
    @_all_beats = []
    @processing_block = 0
    @_data_keys = {}
    @_beat_refs = {}
    found_start = false
    first_starting_line = false
    starting_line = "---"

    for line in @file_contents.split("\n")
      # skip comments
      unless line.indexOf("#") == 0
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

    @processing_block = -1
    @_all_beats

  process_line: (line) ->
    line = line.trim()
    return false unless line.length

    __log "BeatsData: process line '#{line}'"

    # start of collection block
    if line.match(/^collection do/)?
      @start_block "collection", line.substr(line.indexOf(" do ") + 4)
    # end of some block
    else if line == "end"
      @end_block()
    else if line.indexOf("$") == 0
      # a beat definition
      if line.indexOf(",") > -1
        @store_beat line
      # a beat reference
      else
        if @processing_block == "collection"
          @add_beat_to_collection_by_ref line

  add_beat_to_collection_by_ref: (ref) ->
    beat = @get_beat_from_ref ref
    return false unless beat

    @this_block_meta.beat_refs.push ref 
    beat_id = @_beat_refs[ref]
    beat.collection = @this_block_meta.name
    beat.file_path = "#{@this_block_meta.dir}#{beat.file_path}"
    beat.source = if @_config.use_s3
      "#{@_config.s3_path}#{beat.file_path}"
    else
      "#{@_config.beat_root_path}#{beat.file_path}"
    @_all_beats[beat_id] = beat

  store_data_keys: (line) ->
    unless typeof line == "string"
      line = line.toString()

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

  get_block_meta_defaults: (type) ->
    defaults = switch (type)
      when "collection"
        name: "", dir: "", hide: false, beat_refs: []
      else
        {}

    defaults.type = type
    defaults

  start_block: (type, line="") ->
    __log "start block #{type} -- #{line}"
    @processing_block = type
    @this_block_meta = @get_block_meta_defaults type
    # no line no grind
    return unless (line = line.trim()).length

    parts = line.split(",")
    for p in parts
      pair = p.split(":")
      if pair.length > 1
        key = pair[0].trim()

        @this_block_meta[key] = pair[1].trim()

  end_block: ->
    __log ">> end block -- #{@processing_block}"
    switch @processing_block
      when 'collection' then 1

    @blocks.push _.clone @this_block_meta

    @processing_block = 0

  store_beat: (line) ->
    line = line.trim()
    return false unless line.length
    unless line.indexOf("$") == 0
      console.log "ERROR! no ref given for beat on line: '#{line}'"
      return false 

    beat_data = @default_beat_data_clone()
    matched_lists = line.match(/\[([a-zA-Z,\s]+)\]/g)
    data_keys = if @processing_block == "collection"
      _.without @_data_keys, "collection" 
    else
      @_data_keys

    if matched_lists?
      for match, i in matched_lists
        matches = match.replace(/[\[|\]]/g, "").split(",")
        matched_lists[i] = []
        for m in matches
          matched_lists[i].push m.trim()

        line = line.replace(match, "__mlist#{i}")

    # must be done after the matched_lists? check above
    # where tags are filtered out otherwise split is
    # done incorrectly
    pieces = line.split(",")
    beat_ref = pieces.shift()

    for piece, i in pieces
      piece = piece.trim()
      # handle special pieces
      if piece.match(/__mlist/)?
        idx = parseInt(piece.replace("__mlist", ""))
        if matched_lists[idx]?
          piece = matched_lists[idx]

      beat_data[data_keys[i]] = piece

    beat_data.type = beat_data.file_path.substr(beat_data.file_path.lastIndexOf(".") + 1)

    if @processing_block == "collection"
      beat_data.collection = @this_block_meta.name
      beat_data.file_path = "#{@this_block_meta.dir}#{beat_data.file_path}"
      @this_block_meta.beat_refs.push beat_ref

    # generated properties
    beat_data.source = if @_config.use_s3
      "#{@_config.s3_path}#{beat_data.file_path}"
    else
      "#{@_config.beat_root_path}#{beat_data.file_path}"

    # lastly - add it to the list
    @_all_beats.push beat_data
    if @_beat_refs[beat_ref]?
      console.log "beat reference already stored for '#{beat_ref}'"
    else
      @_beat_refs[beat_ref] = @_all_beats.length - 1

    beat_data

