// Generated by CoffeeScript 1.10.0
(function() {
  var EventTracker, Events,
    slice = [].slice,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BeatLab.Widget = (function() {
    Widget.init = function(id, opts) {
      if (opts == null) {
        opts = {};
      }
      this._instances || (this._instances = []);
      return this._instances.push(new this(id, opts));
    };

    function Widget(container, opts1) {
      this.opts = opts1 != null ? opts1 : {};
      this.container = $(container);
      this.key_bindings = [];
      this.global_key_bindings = [];
      this.setup();
    }

    Widget.prototype.trigger = function() {
      var args, evnt, ref;
      evnt = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      return (ref = this.container).trigger.apply(ref, [evnt].concat(slice.call(args)));
    };

    Widget.prototype.on = function(evnt, fn) {
      if (!this.container.length) {
        return console.error("event attached to widget with no container");
      }
      return this.container.on(evnt, fn);
    };

    Widget.prototype.before_setup = function() {
      return 1;
    };

    Widget.prototype.ready = function() {
      return 1;
    };

    Widget.prototype.setup_events = function() {
      return 1;
    };

    Widget.prototype.dispatch = function(evnt, map) {
      return this.on(evnt, (function(_this) {
        return function(e) {
          var $el, fn, key, prevent, results;
          $el = $(e.target);
          results = [];
          for (key in map) {
            fn = map[key];
            if ($el.is(key) || $el.hasClass("" + key)) {
              prevent = fn.apply(_this, [$el, e]);
              if (prevent) {
                results.push(e.preventDefault());
              } else {
                results.push(void 0);
              }
            } else {
              results.push(void 0);
            }
          }
          return results;
        };
      })(this));
    };

    Widget.prototype.setup = function() {
      this.should_render = false;
      this.before_setup();
      this.setup_events();
      this.setup_key_handlers();
      this.ready();
      return this.render();
    };

    Widget.prototype.bind_key = function(key, fn, global) {
      if (global == null) {
        global = false;
      }
      if (!_.isArray(key)) {
        key = [key];
      }
      if (global) {
        return this.global_key_bindings.push([key, fn]);
      } else {
        return this.key_bindings.push([key, fn]);
      }
    };

    Widget.prototype.setup_key_handlers = function() {
      var fire_key_event;
      fire_key_event = (function(_this) {
        return function(keycode, bindings, e) {
          var binding, i, len;
          for (i = 0, len = bindings.length; i < len; i++) {
            binding = bindings[i];
            if (_.indexOf(binding[0], keycode) > -1) {
              return binding[1].call(_this, e);
            }
          }
          return false;
        };
      })(this);
      if (!_.isEmpty(this.key_bindings)) {
        this.container.on("keydown", (function(_this) {
          return function(e) {
            var prevent;
            prevent = fire_key_event(e.keyCode, _this.key_bindings, e);
            console.log("prevent", prevent);
            if (prevent) {
              return e.preventDefault();
            }
          };
        })(this));
      }
      if (!_.isEmpty(this.global_key_bindings)) {
        return $(document.body).on("keydown", (function(_this) {
          return function(e) {
            var prevent;
            prevent = fire_key_event(e.keyCode, _this.global_key_bindings, e);
            if (prevent) {
              return e.preventDefault();
            }
          };
        })(this));
      }
    };

    Widget.prototype.render = function() {
      if (!this.should_render) {
        return;
      }
      this.should_render = false;
      return true;
    };

    return Widget;

  })();

  Events = {};

  EventTracker = (function() {
    function EventTracker(debug) {
      var _gaq;
      this.debug = debug != null ? debug : false;
      if (typeof _gaq === "undefined" || _gaq === null) {
        _gaq = [];
      }
      this.setup_events();
    }

    EventTracker.prototype.setup_events = function() {
      return $('body').on('click', '[data-track-click-event]', (function(_this) {
        return function(e) {
          return _this.event($(_this).data('track-click-event'));
        };
      })(this));
    };

    EventTracker.prototype.track_event = function(cat, action, value, other) {
      var i, len, track, val;
      track = ['_trackEvent'];
      if (_.isArray(cat)) {
        for (i = 0, len = cat.length; i < len; i++) {
          val = cat[i];
          track.push(val);
        }
      } else {
        if (cat) {
          track.push(cat);
        }
        if (action) {
          track.push(action);
        }
        if (value) {
          track.push(value);
        }
        if (other) {
          track.push(other);
        }
      }
      _gaq.push(track);
      if (this.debug) {
        return console.log(track);
      }
    };

    EventTracker.prototype.event = function(key) {
      if (!_.has(Events, key)) {
        return;
      }
      return this.track_event(Events[key]);
    };

    return EventTracker;

  })();

  $(function() {
    return BeatLab.event_tracker = new EventTracker(1);
  });

  BeatLab.Home = (function(superClass) {
    extend(Home, superClass);

    function Home() {
      return Home.__super__.constructor.apply(this, arguments);
    }

    Home.prototype.before_setup = function() {
      this.tracks_data = JSON.parse($(".tracks_data").text());
      return this.player = new BeatLab.Player(this.container.find(".beatlab_player"), {
        playlist: this.tracks_data
      });
    };

    Home.prototype.setup_events = function() {
      return this.dispatch("click", {
        select_track_btn: (function(_this) {
          return function($el) {
            return _this.player.load_playlist_track_at($el.data("idx"));
          };
        })(this)
      });
    };

    return Home;

  })(BeatLab.Widget);

  BeatLab.Player = (function() {
    function Player(container, opts1) {
      this.opts = opts1 != null ? opts1 : {};
      this.container = $(container);
      this.audio = this.container.find("audio");
      this.track_meta = this.container.find(".track_meta");
      this.setup_events();
      if (this.opts.playlist) {
        this.load_playlist(this.opts.playlist);
      }
    }

    Player.prototype.setup_events = function() {
      if (!this.opts.no_key_events) {
        $(window).keydown((function(_this) {
          return function(e) {
            console.log(e.keyCode);
            switch (e.keyCode) {
              case 32:
                return _this.toggle_play();
              case 39:
                return _this.load_next_track_in_playlist();
              case 37:
                return _this.load_prev_track_in_playlist_or_reload();
            }
          };
        })(this));
      }
      this.audio.on("play", (function(_this) {
        return function() {
          return _this.is_playing = true;
        };
      })(this));
      this.audio.on("pause", (function(_this) {
        return function() {
          return _this.is_playing = false;
        };
      })(this));
      this.audio.on("ended", (function(_this) {
        return function() {
          return _this.track_ended();
        };
      })(this));
      return this.audio.on("canplay", (function(_this) {
        return function() {
          if (_this.autoplay) {
            return _this.play();
          }
        };
      })(this));
    };

    Player.prototype.load_playlist = function(playlist) {
      this.playlist = playlist;
      this.current_playlist_index = 0;
      return this.load_track(this.playlist[0]);
    };

    Player.prototype.load_track = function(track) {
      this.audio.find("source").attr("src", track.source);
      this.audio.find("source").attr("type", "audio/" + (track.type === 'm4a' ? 'mp4' : track.type));
      this.track_meta.find(".title").text(track.title);
      return this.audio.load();
    };

    Player.prototype.toggle_play = function() {
      if (this.is_playing) {
        return this.pause();
      } else {
        return this.play();
      }
    };

    Player.prototype.play = function() {
      return this.audio[0].play();
    };

    Player.prototype.pause = function() {
      this.autoplay = false;
      return this.audio[0].pause();
    };

    Player.prototype.mute = function() {
      return this.audio[0].muted = true;
    };

    Player.prototype.unmute = function() {
      return this.audio[0].muted = false;
    };

    Player.prototype.toggle_mute = function() {
      if (this.audio.muted) {
        return this.unmute();
      } else {
        return this.mute();
      }
    };

    Player.prototype.set_volume = function() {};

    Player.prototype.track_ended = function() {
      return this.load_next_track_in_playlist();
    };

    Player.prototype.load_playlist_track_at = function(idx) {
      idx = Math.max(0, idx);
      this.autoplay = true;
      this.current_playlist_index = idx;
      if (this.current_playlist_index > this.playlist.length) {
        return;
      }
      return this.load_track(this.playlist[this.current_playlist_index]);
    };

    Player.prototype.load_next_track_in_playlist = function() {
      if (!this.playlist) {
        return;
      }
      this.autoplay = true;
      if (this.current_playlist_index != null) {
        this.current_playlist_index += 1;
      } else {
        this.current_playlist_index = 0;
      }
      if (this.current_playlist_index > this.playlist.length) {
        return this.playlist_ended();
      }
      return this.load_playlist_track_at(this.current_playlist_index);
    };

    Player.prototype.load_prev_track_in_playlist_or_reload = function() {
      if (!this.playlist) {
        return;
      }
      this.autoplay = true;
      if (this.audio[0].currentTime > 10) {
        return this.audio[0].currentTime = 0;
      } else {
        return this.load_playlist_track_at(this.current_playlist_index - 1);
      }
    };

    Player.prototype.playlist_ended = function() {
      this.autoplay = false;
      return this.load_playlist_track_at(0);
    };

    return Player;

  })();

}).call(this);
