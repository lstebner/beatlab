class App.View
  constructor: (@data={}, @req, @res, @app) ->
    @js_opts = {}
    @default_data()
    @set_view @data.view
    
  default_data: ->
    @data = _.extend
      layout: true
      title: App.conf "site_name"
      site_name: App.conf "site_name"
      meta:
        keywords: App.conf "site_keywords"
        description: App.conf "site_description"
      this_url: @req.url
      _: _
      view: 'index'
      disqus_shortname: App.conf("disqus_shortname")
      cookies: null
      body_class: ''
      single_upload_view: false
      this_url: @req.url
      pagination_data: {}
      uploads_filter: {}
      load_more: true
      display_comments: false
      no_uploads_message: false
      css_version: App.conf("css_version")
      js_version: App.conf("js_version")
      base_url: App.base_url()
      auto_generated_id: @auto_generate_id()
      js_opts: @js_opts
      compiled_js: false
      ,@data 

    @data

  auto_generate_id: ->
    "auto_id_#{(new Date()).getTime().toString(36)}"

  add_js_opts: (new_opts={}) ->
    @js_opts = _.extend @js_opts, new_opts

  set_view: (@view) ->

  set_data: (key, val) ->
    @data[key] = val

  extend_data: (more_data={}) ->
    @data = _.extend @data, more_data

  js_block: -> false

  render: ->
    @add_js_opts @data.js_opts if @data.js_opts

    @data.compiled_js = @js_block()

    @res.render @view, _.extend(App.get_conf(), @data, {js_opts: JSON.stringify(@js_opts)})






