BeatLab = BeatLab || {}

class BeatLab.Query
  constructor: (@beats_data) ->

  get_beats: (q={}) ->
    if q.tags
      @get_beats_tagged q.tags
    else
      @get_all_beats()
  
  get_all_beats: ->
    @beats_data._all_beats

  get_beats_tagged: (tags=[], match_all=false) ->
    if typeof tags == "string"
      tags = [tags]

    found = []

    for beat in @beats_data._all_beats
      this_matched = 0
      for t in tags
        if beat.tags.indexOf(t) > -1
          this_matched++

      should_add = (match_all && this_matched == tags.length) || (!match_all && this_matched)

      if should_add
        found.push beat

    found

  get_beats_for_collection: (collection) ->
    if typeof collection == "string"
      collection = @get_collection collection, false
      unless collection?
        console.log "ERROR get_beats_for_collection could not find collection"
        return []

    found = []
    for ref in collection.beat_refs
      if beat = @beats_data.get_beat_from_ref(ref)
        found.push beat

    found

  get_collection: (collection, include_beats=false) ->
    coll = null
    for c in @beats_data.get_blocks("collection")
      if c.name == collection
        coll = _.clone c

    if include_beats
      coll.beats = @get_beats_for_collection coll

    coll

