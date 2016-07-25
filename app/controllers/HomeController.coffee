class App.HomeController extends BeatLab.Controller
  {} = Requires
  query = new BeatLab.Query(beats_data)

  name: "HomeController"
  view_class: BeatLab.HomeView

  setup: ->
    @public_methods = ["index"]
    @requires "tracks", "index"
    super

  load: (load_what) ->
    return unless super

    if load_what.indexOf("tracks") > -1
      @load_tracks()
      @loaded "tracks"

  load_tracks: ->
    track = (filename, title, playlist="") ->
      filename = "https://s3-us-west-1.amazonaws.com/beatlabio/#{filename}"

      if !title?
        title = filename

      type = filename.substr(filename.lastIndexOf(".") + 1)

      {
        source: filename
        title: title
        type: type
        playlist: playlist
      }

    @tracks = query.get_beats()

  index: ->
    @view_data.tracks = @tracks
    
    @render "index"

