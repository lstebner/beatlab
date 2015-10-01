class App.HomeController extends BeatLab.Controller
  {} = Requires
  query = BeatLab.Query

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
    track = (filename, title) ->
      if !title?
        title = filename

      type = filename.substr(filename.indexOf(".") + 1)

      {
        source: "/beats/#{filename}" 
        title: title
        type: type
      }

    @tracks = [
      track "morningbeat093015.wav", "Morning Beat 9/30/15"
      track "eveningbeat092815.wav", "Evening Beat 9/28/15"
      track "morningbeat092115_3.wav", "Morning Beat 9/21/15"
      track "morningbeat091715.wav", "Morning Beat 9/17/15"
      track "morningbeat091015.wav", "Morning Beat 9/10/15"
      track "morningbeat090415.wav", "Morning Beat 9/04/15"
    ]

  index: ->
    @view_data.tracks = @tracks
    
    @render "index"

