class BeatLab.Home extends BeatLab.Widget
  before_setup: ->
    #don't tell anyone about this selector
    @tracks_data = JSON.parse $(".tracks_data").text()
    @player = new BeatLab.Player @container.find(".beatlab_player"), playlist: @tracks_data

  setup_events: ->
    @dispatch "click", {
      select_track_btn: ($el) =>
        @player.load_playlist_track_at $el.data("idx")
    }


