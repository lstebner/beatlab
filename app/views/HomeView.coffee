class BeatLab.HomeView extends App.View
  js_block: ->
    """
    World.Home.init("##{@data.auto_generated_id}", #{JSON.stringify(@data.js_opts)});
    """
