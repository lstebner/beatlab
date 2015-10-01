class App.HomeController extends BeatLab.Controller
  {} = Requires
  query = BeatLab.Query

  name: "HomeController"
  view_class: BeatLab.HomeView

  setup: ->
    @public_methods = ["index"]
    super

  load: (load_what) ->
    return unless super

  index: ->
    @render "index"

