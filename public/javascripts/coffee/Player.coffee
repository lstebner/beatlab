class BeatLab.Player
  constructor: (container, @opts={}) ->
    @container = $ container
    @audio = @container.find("audio")
    @track_meta = @container.find(".track_meta")

    @setup_events()
    @load_playlist(@opts.playlist) if @opts.playlist

  setup_events: ->
    unless @opts.no_key_events
      $(window).keydown (e) =>
        console.log e.keyCode
        switch e.keyCode
          when 32 then @toggle_play()
          when 39 then @load_next_track_in_playlist()
          when 37 then @load_prev_track_in_playlist_or_reload()

    @audio.on "play", => @is_playing = true
    @audio.on "pause", => @is_playing = false
    @audio.on "ended", => @track_ended()
    @audio.on "canplay", => @play() if @autoplay

  load_playlist: (@playlist) ->
    @current_playlist_index = 0
    @load_track @playlist[0]

  load_track: (track) ->
    @audio.find("source").attr "src", track.source
    @audio.find("source").attr "type", "audio/#{if track.type == 'm4a' then 'mp4' else track.type}"
    @track_meta.find(".title").text track.title
    @audio.load()

  toggle_play: ->
    if @is_playing
      @pause()
    else
      @play()

  play: ->
    @audio[0].play()

  pause: ->
    @autoplay = false
    @audio[0].pause()

  mute: ->
    @audio[0].muted = true

  unmute: ->
    @audio[0].muted = false

  toggle_mute: ->
    if @audio.muted then @unmute() else @mute()

  set_volume: ->

  track_ended: ->
    @load_next_track_in_playlist()

  load_playlist_track_at: (idx) ->
    idx = Math.max 0, idx
    @autoplay = true
    @current_playlist_index = idx
    return if @current_playlist_index > @playlist.length
    @load_track @playlist[@current_playlist_index]

  load_next_track_in_playlist: ->
    return unless @playlist
    @autoplay = true
    if @current_playlist_index?
      @current_playlist_index += 1
    else
      @current_playlist_index = 0

    return @playlist_ended() if @current_playlist_index > @playlist.length

    @load_playlist_track_at(@current_playlist_index) 

  load_prev_track_in_playlist_or_reload: ->
    return unless @playlist
    @autoplay = true
    if @audio[0].currentTime > 10
      @audio[0].currentTime = 0
    else
      @load_playlist_track_at @current_playlist_index - 1 

  playlist_ended: ->
    @autoplay = false
    @load_playlist_track_at 0












