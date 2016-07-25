class App.HomeController extends BeatLab.Controller
  {} = Requires
  query = new BeatLab.Query()

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

    @tracks = query.get_beats_for_collection("Headhunters").beats
    console.log "da beats", @tracks

    # @tracks = [
    #   track "headhunters/01 morningbeat111115_5.wav", "Morning Beat 11/11/15", "Headhunters"
    #   track "headhunters/02 morningbeat112515_3.wav", "Morning Beat 11/25/15", "Headhunters"
    #   track "headhunters/03 morningbeat120115_4.wav", "Morning Beat 12/01/15", "Headhunters"
    #   track "headhunters/04 morningbeat112015_7.wav", "Morning Beat 11/20/15", "Headhunters"
    #   track "headhunters/05 morningbeat120315_4.wav", "Morning Beat 12/03/15", "Headhunters"
    #   track "headhunters/06 morningbeat112115_6.wav", "Morning Beat 11/21/15", "Headhunters"
    #   track "headhunters/07 morningbeat102815_5.wav", "Morning Beat 10/28/15", "Headhunters"

      # track "morning_beats/2015_11/morningbeat111115_3.wav", "Morning Beat 11/11/15", "Headhunters"
      # track "morning_beats/2015_11/morningbeat112515_2-92bpm.wav", "Morning Beat 11/25/15", "Headhunters"
      # track "morning_beats/2015_12/morningbeat120115.wav", "Morning Beat 12/01/15", "Headhunters"
      # track "morning_beats/2015_11/morningbeat112015_5.wav", "Morning Beat 11/20/15", "Headhunters"
      # track "morning_beats/2015_12/morningbeat120315_3.wav", "Morning Beat 12/03/15", "Headhunters"
      # track "morning_beats/2015_11/morningbeat112115_2.wav", "Morning Beat 11/21/15", "Headhunters"
      # track "morning_beats/2015_10/morningbeat102815.wav", "Morning Beat 10/28/15", "Headhunters"

      # # December 2015 beats
      # track "morning_beats/2015_12/morningbeat120515.wav", "Morning Beat 12/05/15", "December 2015 Beats"
      # track "morning_beats/2015_12/morningbeat120315.wav", "Morning Beat 12/03/15", "December 2015 Beats"
      # track "morning_beats/2015_12/morningbeat120215.wav", "Morning Beat 12/02/15", "December 2015 Beats"
      # track "morning_beats/2015_12/morningbeat120115.wav", "Morning Beat 12/01/15", "December 2015 Beats"

      # # November 2015 beats
      # track "morning_beats/2015_11/morningbeat112915_3.wav", "Morning Beat 11/29/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat112615.wav", "Morning Beat 11/26/15", "November 2015 Beats"
      # track "morning_beats/2015_11/lunchbeat112515_3.wav", "Lunch Beat 11/25/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat112515.wav", "Morning Beat 11/25/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat112415.wav", "Morning Beat 11/24/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat112315_2.wav", "Morning Beat 11/23/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat112115_2.wav", "Morning Beat 11/21/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat112015_4.wav", "Morning Beat 11/20/15", "November 2015 Beats"
      # track "logic_beats/eveningbeat111915.m4a", "Evening Beat 11/19/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat111815.wav", "Morning Beat 11/18/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat111715_2.wav", "Morning Beat 11/17/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat111515_3.wav", "Morning Beat 11/15/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat111315_4.wav", "Morning Beat 11/13/15", "November 2015 Beats"
      # track "logic_beats/eveningbeat111215_1.m4a", "Evening Beat 11/12/15", "November 2015 Beats"
      # track "morning_beats/2015_11/eveningbeat111115.wav", "Evening Beat 11/11/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat111115_3.wav", "Morning Beat 11/11/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat111015.wav", "Morning Beat 11/10/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat110815.wav", "Morning Beat 11/08/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat110615_2.wav", "Morning Beat 11/06/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat110415_4.wav", "Morning Beat 11/04/15", "November 2015 Beats"
      # track "morning_beats/2015_11/morningbeat110215_2.wav", "Morning Beat 11/02/15", "November 2015 Beats"
      # track "logic_beats/morningbeat110115_1.m4a", "Morning Beat 11/01/15", "November 2015 Beats"

      # # October 2015 beats
      # track "morning_beats/2015_10/morningbeat103015.wav", "Morning Beat 10/30/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat102915.wav", "Morning Beat 10/29/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat102815.wav", "Morning Beat 10/28/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat102715.wav", "Morning Beat 10/27/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat102615.wav", "Morning Beat 10/26/15", "October 2015 Beats"
      # track "morning_beats/2015_10/eveningbeat102315_1.wav", "Evening Beat 10/23/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat102215_4.wav", "Morning Beat 10/22/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat102115.wav", "Morning Beat 10/21/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat101915_3.wav", "Morning Beat 10/19/15", "October 2015 Beats"
      # track "morning_beats/2015_10/eveningbeatrefresh_101715.wav", "Evening Beat 10/17/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat101615.wav", "Morning Beat 10/16/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat101515.wav", "Morning Beat 10/15/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat101415.wav", "Morning Beat 10/14/15", "October 2015 Beats"
      # track "logic_beats/morningbeat101215_5.m4a", "Morning Beat 10/12/15", "October 2015 Beats"
      # track "logic_beats/morningbeat101015_4.m4a", "Morning Beat 10/10/15", "October 2015 Beats"
      # track "logic_beats/morningbeat100915_1.m4a", "Morning Beat 10/09/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat100815_2.wav", "Morning Beat 10/08/15", "October 2015 Beats"
      # track "morning_beats/2015_10/eveningbeat100715.wav", "Evening Beat 10/07/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat100715.wav", "Morning Beat 10/07/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat100515.wav", "Morning Beat 10/05/15", "October 2015 Beats"
      # track "morning_beats/2015_10/morningbeat100115.wav", "Morning Beat 10/01/15", "October 2015 Beats"

      # # September 2015 beats
      # track "morning_beats/2015_09/morningbeat093015_2.wav", "Morning Beat 09/30/15", "September 2015 Beats"
      # track "morning_beats/2015_09/eveningbeat092815.wav", "Evening Beat 09/28/15", "September 2015 Beats"
      # track "morning_beats/2015_09/morningbeat092815.wav", "Morning Beat 09/28/15", "September 2015 Beats"
      # track "morning_beats/2015_09/morningbeat092515.wav", "Morning Beat 09/25/15", "September 2015 Beats"
      # track "morning_beats/2015_09/morningbeat092415_2.wav", "Morning Beat 09/24/15", "September 2015 Beats"
      # track "morning_beats/2015_09/morningbeat092115_3.wav", "Morning Beat 09/21/15", "September 2015 Beats"
      # track "logic_beats/morningbeat091915_2.m4a", "Morning Beat 09/19/15", "October 2015 Beats"
      # track "morning_beats/2015_09/morningbeat091715.wav", "Morning Beat 09/17/15", "September 2015 Beats"
      # track "morning_beats/2015_09/morningbeat091615_3.wav", "Morning Beat 09/16/15", "September 2015 Beats"
      # track "logic_beats/morningbeat091515_10.m4a", "Morning Beat 09/19/15", "October 2015 Beats"
      # track "morning_beats/2015_09/morningbeat091015.wav", "Morning Beat 09/10/15", "September 2015 Beats"
      # track "morning_beats/2015_09/morningbeat090415.wav", "Morning Beat 09/04/15", "September 2015 Beats"
      # track "morning_beats/2015_09/morningbeat090215_3.wav", "Morning Beat 09/02/15", "September 2015 Beats"

      # # August 2015 beats
      # track "morning_beats/2015_08/morningbeat083115.wav", "Morning Beat 08/31/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat082715.wav", "Morning Beat 08/27/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat082615.wav", "Morning Beat 08/26/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat082415_3.wav", "Morning Beat 08/24/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat081915.wav", "Morning Beat 08/19/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat081815.wav", "Morning Beat 08/18/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat081715_3.wav", "Morning Beat 08/17/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat081315.wav", "Morning Beat 08/13/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat081215subbass.wav", "Morning Beat 08/12/15", "August 2015 Beats"
      # track "morning_beats/2015_08/morningbeat081115.wav", "Morning Beat 08/11/15", "August 2015 Beats"

    # ]

  index: ->
    @view_data.tracks = @tracks
    
    @render "index"

