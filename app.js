// Generated by CoffeeScript 1.10.0
(function() {
  var App, BeatLab, BeatsData, HUSH_LOG, Requires, Schema, _, __log, _str, beats_data, beats_data_raw, fs,
    slice = [].slice,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BeatLab = {};

  _ = require('underscore');

  _str = require('underscore.string');

  Requires = {
    express: require('express'),
    http: require('http'),
    path: require('path'),
    mongoose: require('mongoose'),
    fs: require('fs')
  };

  Requires.Schema = Requires.mongoose.Schema;

  App = (function() {
    var CONF_DEFAULTS, ROOT_DIR, express, fs;

    fs = Requires.fs, express = Requires.express;

    CONF_DEFAULTS = {
      title: "",
      base_url: '',
      meta_keywords: '',
      meta_description: '',
      css_version: 1,
      js_version: 1,
      port: 3000,
      debug: false
    };

    ROOT_DIR = __dirname.replace(/spec(\/|)/, "");

    App.set_site = function(site) {
      this.site = site;
    };

    App.init = function(opts, appclass) {
      if (opts == null) {
        opts = {};
      }
      if (appclass == null) {
        appclass = App;
      }
      if (appclass === App) {
        return this.site = new App(opts);
      } else {
        return this.site = appclass["init"](opts);
      }
    };

    App.slugify = function(title, d) {
      var replace, str;
      replace = "-";
      str = title.toString().replace(/[\s\.]+/g, replace).toLowerCase().replace(new RegExp("[^a-z0-9" + replace + "]", "g"), replace).replace(new RegExp(replace + "+", "g"), replace);
      if (str.charAt(str.length - 1) === replace) {
        str = str.substring(0, str.length - 1);
      }
      if (str.charAt(0) === replace) {
        str = str.substring(1);
      }
      if (d != null) {
        return str + "-" + d.getDate() + "-" + (d.getMonth() + 1) + "-" + d.getFullYear();
      } else {
        return str;
      }
    };

    App.pretty_date = function(date) {
      return moment(date).fromNow();
    };

    App.base_url = function(uri, force_full) {
      var ref;
      if (force_full == null) {
        force_full = false;
      }
      return (ref = this.site) != null ? ref.base_url(uri, force_full) : void 0;
    };

    App.conf = function(key) {
      var ref;
      return (ref = this.site) != null ? ref.conf(key) : void 0;
    };

    App.get_conf = function() {
      var ref;
      return (ref = this.site) != null ? ref.config : void 0;
    };

    function App(opts) {
      if (opts == null) {
        opts = {};
      }
      this.env = process.env.NODE_ENV;
      this.site_name = opts.site_name, this.config = opts.config, this.app = opts.app, this.mongoose = opts.mongoose;
      this.config = _.extend(CONF_DEFAULTS, this.config || {});
      this.load_environment_config();
      this.setup();
    }

    App.prototype.load_environment_config = function() {
      var contents, e, env_conf, error, filepath;
      filepath = ROOT_DIR + "/app/conf/" + this.env + ".conf";
      contents = fs.readFileSync(filepath, "UTF-8");
      try {
        env_conf = JSON.parse(contents);
        this.config = _.extend(this.config, env_conf);
        if (this.config.debug) {
          return console.log(this.env + " config loaded");
        }
      } catch (error) {
        e = error;
        if (this.config.debug) {
          return console.log("error! parsing json in " + this.env + " conf");
        }
      }
    };

    App.prototype.before_ready = function() {
      return 1;
    };

    App.prototype.setup = function() {
      var key, val;
      for (key in Requires) {
        val = Requires[key];
        this[key] = val;
      }
      this.configure_app();
      this.router = new App.Router(this.app);
      this.setup_mongoose();
      this.setup_routes();
      this.listener = this.app.listen(this.config.port);
      if (this.listener) {
        if (this.config.debug) {
          console.log("Express server listening on port %d in %s mode", this.listener.address().port, this.app.settings.env);
        }
      } else {
        if (this.config.debug) {
          console.log("listener did not start");
        }
      }
      this.before_ready();
      this.is_setup = true;
      return this.ready();
    };

    App.prototype.ready = function() {
      return 1;
    };

    App.prototype.setup_mongoose = function() {
      return this.mongoose.connect("mongodb://" + (this.conf('db_host')) + "/" + (this.conf('db_name')));
    };

    App.prototype.conf = function(key) {
      var ref;
      if ((key != null) && ((ref = this.config) != null ? ref.hasOwnProperty(key) : void 0)) {
        return this.config[key];
      } else {
        return false;
      }
    };

    App.prototype.base_url = function(uri, force_full) {
      var url;
      if (uri == null) {
        uri = "/";
      }
      if (force_full == null) {
        force_full = false;
      }
      if (process.env.NODE_ENV === 'development' && !force_full) {
        return uri;
      }
      return url = "" + (this.conf('base_url')) + uri;
    };

    App.prototype.route = function(uri, dest, type) {
      var controller, controller_name, default_method, dest_sp, dest_wedge, method_name;
      if (type == null) {
        type = "get";
      }
      default_method = "index";
      dest_wedge = "#";
      dest_sp = dest.split(dest_wedge);
      controller_name = dest_sp[0].substr(0, 1).toUpperCase() + dest_sp[0].substring(1);
      controller = App[controller_name + "Controller"];
      if (controller == null) {
        return (this.config.debug ? console.log("App route error, controller not found: " + controller_name) : false);
      }
      method_name = dest_sp[1] != null ? dest_sp[1] : default_method;
      switch (type) {
        case "get":
          return this.router.get(uri, controller, method_name);
        case "post":
          return this.router.post(uri, controller, method_name);
      }
    };

    App.prototype.setup_routes = function() {
      this.route("/sitemap", "sitemap");
      this.route("/post/:slug", "post#index");
      this.route("/category/:category", "listing#by_category");
      this.route("/tag/:tag", "listing#by_tag");
      this.route("/blog", "listing#latest");
      this.route("/store", "store");
      this.route("/about-me", "home#about");
      return this.route("/", "home");
    };

    App.prototype.configure_app = function() {
      express = express;
      this.always_configure();
      switch (this.app.get("env")) {
        case "development":
          this.app.use(express.errorHandler({
            dumpExceptions: true,
            showStack: true
          }));
          this.configure_for_development();
          break;
        case "production":
          this.app.use(express.errorHandler());
          this.configure_for_production();
      }
      return this.is_configured = true;
    };

    App.prototype.always_configure = function() {
      this.app.set("views", ROOT_DIR + "/views");
      this.app.set("view engine", "jade");
      this.app.use(express.bodyParser());
      this.app.use(express.methodOverride());
      this.app.use(this.app.router);
      return this.app.use(express["static"](ROOT_DIR + "/public"));
    };

    App.prototype.configure_for_development = function() {
      return 1;
    };

    App.prototype.configure_for_production = function() {
      return 1;
    };

    return App;

  })();

  App.Schemas = {};

  Schema = Requires.Schema;

  App.Schemas.Project = new Schema({
    title: {
      type: String,
      required: true
    },
    order: {
      type: Number,
      "default": 0
    },
    slug: {
      type: String,
      require: true,
      unique: true
    },
    description: {
      type: String,
      "default": ""
    },
    display_url: {
      type: String,
      "default": ""
    },
    full_url: {
      type: String,
      defalut: ""
    },
    technologies: {
      type: Schema.Types.Mixed,
      "default": []
    },
    images: {
      type: Schema.Types.Mixed,
      "default": []
    },
    archived: {
      type: Boolean,
      "default": false
    },
    group: {
      type: String,
      "default": "default"
    }
  });

  App.Models = {
    Project: Requires.mongoose.model("Project", App.Schemas.Project)
  };

  App.Router = (function() {
    Router.debug = true;

    function Router(app, opts1) {
      this.app = app;
      this.opts = opts1 != null ? opts1 : {};
      if (!this.app) {
        throw new Error("an app is required to create a Router");
      }
      this.routes = [];
    }

    Router.prototype.register = function(type, path, controller, method) {
      var new_route;
      if (Router.debug) {
        console.log("router: add_route " + (type.toUpperCase()) + " " + path + ", " + controller.name + "#" + method);
      }
      new_route = [type, path, controller, method];
      this.routes.push(new_route);
      this.app[type](path, (function(_this) {
        return function(req, res) {
          var c;
          c = new controller(req, res);
          if (!c["do"](method)) {
            console.error("method '" + method + "' not found for controller " + controller);
            return _this.do_404(res);
          }
        };
      })(this));
      return new_route;
    };

    Router.prototype.do_404 = function(res) {
      return res.status(404).send("Sorry, page not found!");
    };

    Router.prototype.get = function(path, controller, method) {
      return this.register('get', path, controller, method);
    };

    Router.prototype.post = function(path, controller, method) {
      return this.register('post', path, controller, method);
    };

    Router.prototype.add_routes = function(controller) {
      var data, path, ref, results, route;
      ref = controller.routes;
      results = [];
      for (path in ref) {
        route = ref[path];
        data = {
          type: "get",
          path: path,
          controller: controller,
          method: null
        };
        if (_.isObject(route)) {
          data = _.extend(data, route);
        } else {
          data.method = route;
        }
        results.push(this.register(data.type, data.path, data.controller, data.method));
      }
      return results;
    };

    return Router;

  })();

  App.View = (function() {
    function View(data1, req1, res1, app) {
      this.data = data1 != null ? data1 : {};
      this.req = req1;
      this.res = res1;
      this.app = app;
      this.js_opts = {};
      this.default_data();
      this.set_view(this.data.view);
    }

    View.prototype.default_data = function() {
      this.data = _.extend({
        layout: true,
        title: App.conf("title"),
        site_name: App.conf("site_name"),
        meta: {
          keywords: App.conf("site_keywords"),
          description: App.conf("site_description")
        },
        this_url: this.req.url,
        _: _,
        view: 'index',
        disqus_shortname: App.conf("disqus_shortname"),
        cookies: null,
        body_class: '',
        this_url: this.req.url,
        display_comments: false,
        css_version: App.conf("css_version"),
        js_version: App.conf("js_version"),
        base_url: App.base_url(),
        auto_generated_id: this.auto_generate_id(),
        js_opts: this.js_opts,
        compiled_js: false
      }, this.data);
      return this.data;
    };

    View.prototype.auto_generate_id = function() {
      return "auto_id_" + ((new Date()).getTime().toString(36));
    };

    View.prototype.add_js_opts = function(new_opts) {
      if (new_opts == null) {
        new_opts = {};
      }
      return this.js_opts = _.extend(this.js_opts, new_opts);
    };

    View.prototype.set_view = function(view) {
      this.view = view;
    };

    View.prototype.set_data = function(key, val) {
      return this.data[key] = val;
    };

    View.prototype.extend_data = function(more_data) {
      if (more_data == null) {
        more_data = {};
      }
      return this.data = _.extend(this.data, more_data);
    };

    View.prototype.js_block = function() {
      return false;
    };

    View.prototype.render = function() {
      if (this.data.js_opts) {
        this.add_js_opts(this.data.js_opts);
      }
      this.data.compiled_js = this.js_block();
      return this.res.render(this.view, _.extend(App.get_conf(), this.data, {
        js_opts: JSON.stringify(this.js_opts)
      }));
    };

    return View;

  })();

  App.Controller = (function() {
    Controller.prototype.name = "base";

    Controller.prototype.view_class = App.View;

    function Controller(req1, res1) {
      this.req = req1;
      this.res = res1;
      this.requirements_list = {};
      this.loaded_items = [];
      this.current_needs = [];
      this.public_methods = [];
      this.view_data = {};
      this.view_to_render = "";
      this.setup();
    }

    Controller.prototype.setup = function() {
      return this.setup_preload();
    };

    Controller.prototype.setup_preload = function() {
      return 1;
    };

    Controller.prototype.requires = function(needs_list, for_what) {
      var _register, j, l, len, len1, m, methods, ref, results, results1;
      if (for_what == null) {
        for_what = "all";
      }
      if (!_.isArray(needs_list)) {
        needs_list = [needs_list];
      }
      _register = (function(_this) {
        return function(method_name, needs_list) {
          return _this.requirements_list[method_name] = _this.requirements_list[method_name] != null ? _.union(_this.requirements_list[method_name], needs_list) : needs_list;
        };
      })(this);
      if (_.isObject(for_what)) {
        methods = for_what.except != null ? _.difference(this.public_methods, for_what.except) : for_what.only != null ? _.intersection(this.public_methods, for_what.only) : void 0;
        results = [];
        for (j = 0, len = methods.length; j < len; j++) {
          m = methods[j];
          results.push(_register(m, needs_list));
        }
        return results;
      } else if (for_what === "all") {
        ref = this.public_methods;
        results1 = [];
        for (l = 0, len1 = ref.length; l < len1; l++) {
          m = ref[l];
          results1.push(_register(m, needs_list));
        }
        return results1;
      } else {
        return _register(for_what, needs_list);
      }
    };

    Controller.prototype.preload = function(for_method) {
      if (this.requirements_list[for_method] == null) {
        return true;
      }
      this.current_needs = this.requirements_list[for_method];
      return this.load(this.current_needs.join(" "));
    };

    Controller.prototype["do"] = function(requested_method, prevent_render) {
      this.requested_method = requested_method;
      this.prevent_render = prevent_render != null ? prevent_render : true;
      this.preload(this.requested_method);
      if (this.has_needs_met()) {
        if ((this[this.requested_method] != null) && _.indexOf(this.public_methods, this.requested_method) > -1) {
          this[this.requested_method]();
          if (!this.prevent_render) {
            this.render();
          }
          true;
        } else {
          console.log("method not found or not public", this.name + "::" + this.requested_method);
          this.do_404();
        }
      } else {
        setTimeout((function(_this) {
          return function() {
            return _this["do"](_this.requested_method, _this.prevent_render);
          };
        })(this), 50);
      }
      return true;
    };

    Controller.prototype.do_404 = function() {
      this.res.status(404);
      return this.res.render('404', {
        title: ' 404, man'
      });
    };

    Controller.prototype.param = function(key) {
      if (this.req.params.hasOwnProperty(key)) {
        return this.req.params[key];
      } else {
        return false;
      }
    };

    Controller.prototype.query = function(key) {
      if (this.req.query.hasOwnProperty(key)) {
        return this.req.query[key];
      } else {
        return false;
      }
    };

    Controller.prototype.cookie = function(key) {
      if (this.req.cookies && this.req.cookies.hasOwnProperty(key)) {
        return this.req.cookies[key];
      } else {
        return false;
      }
    };

    Controller.prototype.body = function(key) {
      if (this.req.body && this.req.body.hasOwnProperty(key)) {
        return this.req.body[key];
      } else {
        return false;
      }
    };

    Controller.prototype.redirect = function(dest, status) {
      if (status == null) {
        status = 302;
      }
      return this.res.redirect(status, dest);
    };

    Controller.prototype.load = function(load_items) {
      var i, j, len, ref;
      if (this.loaded_items) {
        ref = this.loaded_items;
        for (j = 0, len = ref.length; j < len; j++) {
          i = ref[j];
          load_items = load_items.replace("" + i, "");
        }
        load_items = _str.trim(load_items.replace(/\s\s/g, ""));
      } else {
        this.loaded_items = [];
      }
      if (!load_items.length) {
        return false;
      }
      return true;
    };

    Controller.prototype.loaded = function(item_name) {
      this.loaded_items || (this.loaded_items = []);
      return this.loaded_items.push(item_name);
    };

    Controller.prototype.has_needs_met = function() {
      var has_everything, j, len, need, ref;
      if (_.isEmpty(this.current_needs)) {
        return true;
      }
      has_everything = true;
      ref = this.current_needs;
      for (j = 0, len = ref.length; j < len; j++) {
        need = ref[j];
        has_everything = has_everything && _.indexOf(this.loaded_items, need) > -1;
      }
      return has_everything;
    };

    Controller.prototype.json = function(obj) {
      return this.res.json(obj);
    };

    Controller.prototype.render = function(view_name, data) {
      if (view_name == null) {
        view_name = null;
      }
      if (data == null) {
        data = this.view_data;
      }
      if (!this.view_class) {
        return false;
      }
      this.before_render();
      if (this.cancel_render) {
        return this.cancel_render = false;
      }
      this.view_data.view = !_.isEmpty(view_name) ? view_name : !_.isEmpty(this.view_to_render) ? this.view_to_render : this.requested_method;
      this.current_view = new this.view_class(this.view_data, this.req, this.res, this.app);
      this.current_view.render();
      this.after_render();
      this.cancel_render = false;
      return this.current_view;
    };

    Controller.prototype.set_view = function(view_to_render) {
      this.view_to_render = view_to_render;
      return 1;
    };

    Controller.prototype.before_render = function() {
      return 1;
    };

    Controller.prototype.after_render = function() {
      return 1;
    };

    return Controller;

  })();

  HUSH_LOG = false;

  __log = function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if (!HUSH_LOG) {
      return console.log.apply(console, args);
    }
  };

  fs = require("fs");

  beats_data_raw = fs.readFileSync("./beats_data.txt", "UTF-8");

  BeatsData = (function() {
    function BeatsData(file_contents, config) {
      this.file_contents = file_contents;
      if (config == null) {
        config = {};
      }
      this.setup_config(config);
      if (this.file_contents != null) {
        this.process();
      }
    }

    BeatsData.prototype.setup_config = function(config) {
      var defaults;
      if (config == null) {
        config = {};
      }
      defaults = {
        use_s3: true,
        s3_path: "https://s3-us-west-1.amazonaws.com/beatlabio/",
        beat_root_path: "/beats/"
      };
      return this.config = _.extend(defaults, config);
    };

    BeatsData.prototype.get_blocks = function(type) {
      var block, found, j, len, ref;
      if (type == null) {
        type = null;
      }
      if (type != null) {
        found = [];
        ref = this.blocks;
        for (j = 0, len = ref.length; j < len; j++) {
          block = ref[j];
          if (block.type === type) {
            found.push(block);
          }
        }
        return found;
      } else {
        return this.blocks;
      }
    };

    BeatsData.prototype.process = function() {
      var first_starting_line, found_start, j, len, line, ref, starting_line;
      __log("BeatsData: beginning process");
      this.blocks = [];
      this._all_beats = [];
      this.processing_block = 0;
      this._data_keys = {};
      found_start = false;
      first_starting_line = false;
      starting_line = "---";
      ref = this.file_contents.split("\n");
      for (j = 0, len = ref.length; j < len; j++) {
        line = ref[j];
        if (first_starting_line) {
          __log("BeatsData: store_data_keys " + line);
          this.store_data_keys(line);
          first_starting_line = false;
        } else if (!found_start && line.trim() === starting_line) {
          __log("BeatsData: found start");
          found_start = true;
          first_starting_line = true;
        } else if (found_start) {
          this.process_line(line);
        }
      }
      return this._all_beats;
    };

    BeatsData.prototype.process_line = function(line) {
      line = line.trim();
      if (!line.length) {
        return;
      }
      __log("BeatsData: process line " + line);
      if (line.match(/^collection do/) != null) {
        return this.start_block("collection", line.substr(line.indexOf(" do ") + 4));
      } else if (line === "end") {
        return this.end_block();
      } else {
        return this.store_beat(line);
      }
    };

    BeatsData.prototype.store_data_keys = function(line) {
      var j, k, len, ref, results;
      this._data_keys = [];
      ref = line.split(",");
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        k = ref[j];
        results.push(this._data_keys.push(k.trim()));
      }
      return results;
    };

    BeatsData.prototype.default_beat_data_clone = function() {
      var _defaults, j, key, len, ref;
      if (this._defaults) {
        return this._beat_data_defaults;
      }
      _defaults = {
        file_path: "",
        title: "",
        collection: "",
        version: 0,
        created_on: null,
        updated_on: null,
        tags: []
      };
      ref = this._data_keys;
      for (j = 0, len = ref.length; j < len; j++) {
        key = ref[j];
        if (_defaults[key] == null) {
          _defaults[key] = "";
        }
      }
      return this._beat_data_defaults = _defaults;
    };

    BeatsData.prototype.start_block = function(type, line) {
      var j, key, len, p, pair, parts, results;
      __log("start block " + type + " -- " + line);
      this.processing_block = type;
      this.this_block_meta = {
        name: "",
        dir: "",
        hide: false,
        type: type
      };
      parts = line.split(",");
      results = [];
      for (j = 0, len = parts.length; j < len; j++) {
        p = parts[j];
        pair = p.split(":");
        if (pair.length > 1) {
          key = pair[0].trim();
          results.push(this.this_block_meta[key] = pair[1].trim());
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    BeatsData.prototype.end_block = function() {
      switch (this.processing_block) {
        case 'collection':
          1;
      }
      this.blocks.push(_.clone(this.this_block_meta));
      return this.processing_block = 0;
    };

    BeatsData.prototype.store_beat = function(line) {
      var beat_data, data_keys, i, idx, j, l, len, len1, len2, m, match, matched_lists, matches, n, piece, ref;
      line = line.trim();
      beat_data = this.default_beat_data_clone();
      matched_lists = line.match(/\[([a-zA-Z,\s]+)\]/);
      data_keys = this.processing_block === "collection" ? _.without(this._data_keys, "collection") : void 0;
      if (matched_lists != null) {
        for (i = j = 0, len = matched_lists.length; j < len; i = ++j) {
          match = matched_lists[i];
          matches = match.replace(/[\[|\]]/g, "").split(",");
          matched_lists[i] = [];
          for (l = 0, len1 = matches.length; l < len1; l++) {
            m = matches[l];
            matched_lists[i].push(m.trim());
          }
          line = line.replace(match, "__mlist" + i);
        }
      }
      ref = line.split(",");
      for (i = n = 0, len2 = ref.length; n < len2; i = ++n) {
        piece = ref[i];
        piece = piece.trim();
        if (piece.match(/__mlist/) != null) {
          idx = parseInt(piece.replace("__mlist", ""));
          if (matched_lists[idx] != null) {
            piece = matched_lists[idx];
          }
        }
        beat_data[data_keys[i]] = piece;
      }
      beat_data.source = this.config.use_s3 ? "" + this.config.s3_path + beat_data.file_path : "" + this.config.beat_root_path + beat_data.file_path;
      beat_data.type = beat_data.file_path.substr(beat_data.file_path.lastIndexOf(".") + 1);
      if (this.processing_block === "collection") {
        beat_data.collection = this.this_block_meta.name;
      }
      return this._all_beats.push(beat_data);
    };

    return BeatsData;

  })();

  beats_data = new BeatsData(beats_data_raw);

  BeatLab.App = (function(superClass) {
    var express, mongoose;

    extend(App, superClass);

    function App() {
      return App.__super__.constructor.apply(this, arguments);
    }

    express = Requires.express, mongoose = Requires.mongoose, fs = Requires.fs;

    App.init = function(opts) {
      if (opts == null) {
        opts = {};
      }
      return this.site = new BeatLab.App(_.extend({
        app: express(),
        mongoose: mongoose,
        beats_data: beats_data,
        config: {
          port: 3054,
          title: "Kids on the beat, beat kids | BeatLab",
          base_url: 'http://beatlab.io',
          meta_keywords: '',
          meta_description: '',
          css_version: (new Date()).getTime(),
          js_version: (new Date()).getTime()
        },
        opts: opts
      }));
    };

    App.prototype.ready = function() {};

    App.prototype.setup_routes = function() {
      this.route("/", "home#index");
      return this.route("/sitemap", "sitemap#index");
    };

    App.prototype.always_configure = function() {
      var oneYear;
      express = express;
      oneYear = 31557600000;
      this.app.set('port', process.env.PORT || this.conf("port"));
      this.app.set('views', __dirname + '/views');
      this.app.set('view engine', 'jade');
      this.app.use(express.logger('dev'));
      this.app.use(express.cookieParser());
      this.app.use(express.bodyParser());
      this.app.use(express.session({
        secret: 'whateverb34tlabb3r'
      }));
      this.app.use(express.methodOverride());
      this.app.use(express["static"](__dirname + "/public", {
        maxAge: oneYear
      }));
      return this.app.use(this.app.router);
    };

    App.prototype.configure_for_development = function() {
      this.app.use(express.errorHandler());
      return this.app.locals.pretty = true;
    };

    App.prototype.configure_for_production = function() {};

    App.prototype.before_ready = function() {};

    return App;

  })(App);

  BeatLab.Query = (function() {
    function Query() {}

    Query.prototype.get_beats = function(q) {
      if (q == null) {
        q = {};
      }
      if (q.tags) {
        return this.get_beats_tagged(q.tags);
      } else {
        return this.get_all_beats();
      }
    };

    Query.prototype.get_all_beats = function() {
      return beats_data._all_beats;
    };

    Query.prototype.get_beats_tagged = function(tags) {
      var beat, found, j, l, len, len1, ref, t, this_matched;
      if (tags == null) {
        tags = [];
      }
      if (typeof tags === "string") {
        tags = [tags];
      }
      found = [];
      ref = beats_data._all_beats;
      for (j = 0, len = ref.length; j < len; j++) {
        beat = ref[j];
        this_matched = false;
        for (l = 0, len1 = tags.length; l < len1; l++) {
          t = tags[l];
          if (!this_matched && beat.tags.indexOf(t)) {
            this_matched = true;
            found.push(beat);
          }
        }
      }
      return found;
    };

    Query.prototype.get_beats_in_collection = function(collection) {
      var beat, c, coll, collections, found, j, l, len, len1, ref;
      found = [];
      collections = beats_data.get_blocks("collection");
      coll = null;
      for (j = 0, len = collections.length; j < len; j++) {
        c = collections[j];
        if (c.name === collection) {
          coll = _.clone(c);
        }
      }
      if (coll == null) {
        console.log("error finding collection '" + collection + "' in " + (JSON.stringify(collections)));
        return [];
      }
      ref = beats_data._all_beats;
      for (l = 0, len1 = ref.length; l < len1; l++) {
        beat = ref[l];
        if (beat.collection === collection) {
          found.push(beat);
        }
      }
      coll.beats = found;
      return coll;
    };

    return Query;

  })();

  BeatLab.Controller = (function(superClass) {
    extend(Controller, superClass);

    function Controller() {
      return Controller.__super__.constructor.apply(this, arguments);
    }

    return Controller;

  })(App.Controller);

  BeatLab.HomeView = (function(superClass) {
    extend(HomeView, superClass);

    function HomeView() {
      return HomeView.__super__.constructor.apply(this, arguments);
    }

    HomeView.prototype.js_block = function() {
      return "BeatLab.Home.init(\"#" + this.data.auto_generated_id + "\", " + (JSON.stringify(this.data.js_opts)) + ");";
    };

    return HomeView;

  })(App.View);

  App.SitemapController = (function(superClass) {
    extend(SitemapController, superClass);

    function SitemapController() {
      return SitemapController.__super__.constructor.apply(this, arguments);
    }

    SitemapController.prototype.name = "SitemapController";

    SitemapController.prototype.setup = function() {
      this.public_methods = ["index"];
      this.requires("sitemap_urls");
      return SitemapController.__super__.setup.apply(this, arguments);
    };

    SitemapController.prototype.load = function() {
      var j, len, url, urls;
      urls = ["/"];
      this.sitemap_urls = [];
      for (j = 0, len = urls.length; j < len; j++) {
        url = urls[j];
        this.sitemap_urls.push(App.base_url(url, true));
      }
      return this.loaded("sitemap_urls");
    };

    SitemapController.prototype.index = function() {
      this.res.header('Content-type', 'text/plain');
      this.res.end(_.uniq(this.sitemap_urls).join("\n"));
    };

    return SitemapController;

  })(App.Controller);

  App.HomeController = (function(superClass) {
    var query;

    extend(HomeController, superClass);

    function HomeController() {
      return HomeController.__super__.constructor.apply(this, arguments);
    }

    Requires;

    query = new BeatLab.Query();

    HomeController.prototype.name = "HomeController";

    HomeController.prototype.view_class = BeatLab.HomeView;

    HomeController.prototype.setup = function() {
      this.public_methods = ["index"];
      this.requires("tracks", "index");
      return HomeController.__super__.setup.apply(this, arguments);
    };

    HomeController.prototype.load = function(load_what) {
      if (!HomeController.__super__.load.apply(this, arguments)) {
        return;
      }
      if (load_what.indexOf("tracks") > -1) {
        this.load_tracks();
        return this.loaded("tracks");
      }
    };

    HomeController.prototype.load_tracks = function() {
      var track;
      track = function(filename, title, playlist) {
        var type;
        if (playlist == null) {
          playlist = "";
        }
        filename = "https://s3-us-west-1.amazonaws.com/beatlabio/" + filename;
        if (title == null) {
          title = filename;
        }
        type = filename.substr(filename.lastIndexOf(".") + 1);
        return {
          source: filename,
          title: title,
          type: type,
          playlist: playlist
        };
      };
      this.tracks = query.get_beats_in_collection("Headhunters").beats;
      return console.log("da beats", this.tracks);
    };

    HomeController.prototype.index = function() {
      this.view_data.tracks = this.tracks;
      return this.render("index");
    };

    return HomeController;

  })(BeatLab.Controller);

  App.init({}, BeatLab.App);

}).call(this);
