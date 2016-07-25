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
