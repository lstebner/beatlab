// Generated by CoffeeScript 1.10.0
(function() {
  var BeatLab, BeatsData, _, __log, expect, process;

  expect = require("expect.js");

  process = {
    env: {
      NODE_ENV: "test"
    }
  };

  BeatsData = (function() {
    function BeatsData(file_contents, config) {
      this.file_contents = file_contents != null ? file_contents : "";
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
      return this._config = _.extend(defaults, config);
    };

    BeatsData.prototype.config = function(key, val) {
      if (val == null) {
        val = void 0;
      }
      if (key && val !== void 0) {
        this._config[key] = val;
      }
      return this._config[key];
    };

    BeatsData.prototype.get_blocks = function(type) {
      var block, found, j, len, ref1;
      if (type == null) {
        type = null;
      }
      if (type != null) {
        found = [];
        ref1 = this.blocks;
        for (j = 0, len = ref1.length; j < len; j++) {
          block = ref1[j];
          if (block.type === type) {
            found.push(block);
          }
        }
        return found;
      } else {
        return this.blocks;
      }
    };

    BeatsData.prototype.get_beat_from_ref = function(ref) {
      if (this._beat_refs[ref]) {
        return this._all_beats[this._beat_refs[ref]];
      } else {
        return false;
      }
    };

    BeatsData.prototype.process = function() {
      var first_starting_line, found_start, j, len, line, ref1, starting_line;
      __log("BeatsData: beginning process");
      this.blocks = [];
      this._all_beats = [];
      this.processing_block = 0;
      this._data_keys = {};
      this._beat_refs = {};
      found_start = false;
      first_starting_line = false;
      starting_line = "---";
      ref1 = this.file_contents.split("\n");
      for (j = 0, len = ref1.length; j < len; j++) {
        line = ref1[j];
        if (line.indexOf("#") !== 0) {
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
      }
      this.processing_block = -1;
      return this._all_beats;
    };

    BeatsData.prototype.process_line = function(line) {
      var base;
      line = line.trim();
      if (!line.length) {
        return false;
      }
      __log("BeatsData: process line '" + line + "'");
      if (line.match(/^collection do/) != null) {
        return this.start_block("collection", line.substr(line.indexOf(" do ") + 4));
      } else if (line === "end") {
        return this.end_block();
      } else if (line.indexOf("$") === 0) {
        if (line.indexOf(",") > -1) {
          return this.store_beat(line);
        } else {
          if (this.processing_block === "collection") {
            (base = this.this_block_meta).beat_refs || (base.beat_refs = []);
            return this.this_block_meta.beat_refs.push(line);
          }
        }
      }
    };

    BeatsData.prototype.store_data_keys = function(line) {
      var j, k, len, ref1, results;
      if (typeof line !== "string") {
        line = line.toString();
      }
      this._data_keys = [];
      ref1 = line.split(",");
      results = [];
      for (j = 0, len = ref1.length; j < len; j++) {
        k = ref1[j];
        results.push(this._data_keys.push(k.trim()));
      }
      return results;
    };

    BeatsData.prototype.default_beat_data_clone = function() {
      var _defaults, j, key, len, ref1;
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
      ref1 = this._data_keys;
      for (j = 0, len = ref1.length; j < len; j++) {
        key = ref1[j];
        if (_defaults[key] == null) {
          _defaults[key] = "";
        }
      }
      return this._beat_data_defaults = _defaults;
    };

    BeatsData.prototype.get_block_meta_defaults = function(type) {
      var defaults;
      defaults = (function() {
        switch (type) {
          case "collection":
            return {
              name: "",
              dir: "",
              hide: false,
              beat_refs: []
            };
          default:
            return {};
        }
      })();
      defaults.type = type;
      return defaults;
    };

    BeatsData.prototype.start_block = function(type, line) {
      var j, key, len, p, pair, parts, results;
      if (line == null) {
        line = "";
      }
      __log("start block " + type + " -- " + line);
      this.processing_block = type;
      this.this_block_meta = this.get_block_meta_defaults(type);
      if (!(line = line.trim()).length) {
        return;
      }
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
      __log(">> end block -- " + this.processing_block);
      switch (this.processing_block) {
        case 'collection':
          1;
      }
      this.blocks.push(_.clone(this.this_block_meta));
      return this.processing_block = 0;
    };

    BeatsData.prototype.store_beat = function(line) {
      var beat_data, beat_ref, data_keys, i, idx, j, l, len, len1, len2, m, match, matched_lists, matches, n, piece, pieces;
      line = line.trim();
      if (!line.length) {
        return false;
      }
      if (line.indexOf("$") !== 0) {
        console.log("ERROR! no ref given for beat on line: '" + line + "'");
        return false;
      }
      beat_data = this.default_beat_data_clone();
      matched_lists = line.match(/\[([a-zA-Z,\s]+)\]/g);
      data_keys = this.processing_block === "collection" ? _.without(this._data_keys, "collection") : this._data_keys;
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
      pieces = line.split(",");
      beat_ref = pieces.shift();
      for (i = n = 0, len2 = pieces.length; n < len2; i = ++n) {
        piece = pieces[i];
        piece = piece.trim();
        if (piece.match(/__mlist/) != null) {
          idx = parseInt(piece.replace("__mlist", ""));
          if (matched_lists[idx] != null) {
            piece = matched_lists[idx];
          }
        }
        beat_data[data_keys[i]] = piece;
      }
      beat_data.type = beat_data.file_path.substr(beat_data.file_path.lastIndexOf(".") + 1);
      if (this.processing_block === "collection") {
        beat_data.collection = this.this_block_meta.name;
        beat_data.file_path = "" + this.this_block_meta.dir + beat_data.file_path;
        this.this_block_meta.beat_refs.push(beat_ref);
      }
      beat_data.source = this._config.use_s3 ? "" + this._config.s3_path + beat_data.file_path : "" + this._config.beat_root_path + beat_data.file_path;
      this._all_beats.push(beat_data);
      if (this._beat_refs[beat_ref] != null) {
        console.log("beat reference already stored for '" + beat_ref + "'");
      } else {
        this._beat_refs[beat_ref] = this._all_beats.length - 1;
      }
      return beat_data;
    };

    return BeatsData;

  })();

  BeatLab = BeatLab || {};

  BeatLab.Query = (function() {
    function Query(beats_data1) {
      this.beats_data = beats_data1;
    }

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
      return this.beats_data._all_beats;
    };

    Query.prototype.get_beats_tagged = function(tags, match_all) {
      var beat, found, j, l, len, len1, ref1, should_add, t, this_matched;
      if (tags == null) {
        tags = [];
      }
      if (match_all == null) {
        match_all = false;
      }
      if (typeof tags === "string") {
        tags = [tags];
      }
      found = [];
      ref1 = this.beats_data._all_beats;
      for (j = 0, len = ref1.length; j < len; j++) {
        beat = ref1[j];
        this_matched = 0;
        for (l = 0, len1 = tags.length; l < len1; l++) {
          t = tags[l];
          if (beat.tags.indexOf(t) > -1) {
            this_matched++;
          }
        }
        should_add = (match_all && this_matched === tags.length) || (!match_all && this_matched);
        if (should_add) {
          found.push(beat);
        }
      }
      return found;
    };

    Query.prototype.get_beats_for_collection = function(collection) {
      var beat, found, j, len, ref, ref1;
      if (typeof collection === "string") {
        collection = this.get_collection(collection, false);
        if (collection == null) {
          console.log("ERROR get_beats_for_collection could not find collection");
          return [];
        }
      }
      found = [];
      ref1 = collection.beat_refs;
      for (j = 0, len = ref1.length; j < len; j++) {
        ref = ref1[j];
        if (beat = this.beats_data.get_beat_from_ref(ref)) {
          found.push(beat);
        }
      }
      return found;
    };

    Query.prototype.get_collection = function(collection, include_beats) {
      var c, coll, j, len, ref1;
      if (include_beats == null) {
        include_beats = false;
      }
      coll = null;
      ref1 = this.beats_data.get_blocks("collection");
      for (j = 0, len = ref1.length; j < len; j++) {
        c = ref1[j];
        if (c.name === collection) {
          coll = _.clone(c);
        }
      }
      if (include_beats) {
        coll.beats = this.get_beats_for_collection(coll);
      }
      return coll;
    };

    return Query;

  })();

  _ = require("underscore");

  __log = function() {};

  describe("BeatsData", function() {
    var beats, beats_data_raw, data_keys_in_raw, num_beats_in_raw_data, num_collections_in_raw_data;
    beats_data_raw = "this is the test beats data\nthis line above the starting line is just\na big ole comment.\nso do whatever here, it's just going to be\n\n\n..ignored.\n\n---\n# ordered keys, not all are required but they must be in order\nfile_path, title, collection, tags, version, created_on, last_updated_on\n\n$morningbeat111115, 01 morningbeat111115_5.wav, Morning Beat 11/11/15, [chill, unmastered]\n$morningbeat112515, 02 morningbeat112515_3.wav, Morning Beat 11/25/15, [chill, hop hop, instrumental]\n$morningbeat120115, 03 morningbeat120115_4.wav, Morning Beat 12/01/15, [instrumental]\n$morningbeat011516, morningbeat011516_4.wav, Morning beat 01/15/16, [freestyle, instrumental, samples]\n$morningbeat011816, morningbeat011816_3.wav, Morning beat 01/18/16, [scary, themed]\n\ncollection do name: Headhunters, dir: headhunters\n  $morningbeat111115\n  $morningbeat112515\n  $morningbeat120115\nend\n\ncollection do name: January beats\n  $morningbeat011516\n  $morningbeat011816\nend";
    data_keys_in_raw = ["file_path", "title", "collection", "tags", "version", "created_on", "last_updated_on"];
    num_beats_in_raw_data = 5;
    num_collections_in_raw_data = 2;
    beats = null;
    describe("#config", function() {
      before(function() {
        return beats = new BeatsData(beats_data_raw);
      });
      it("creates a config by default", function() {
        beats = new BeatsData();
        return expect(_.isEmpty(beats._config)).to.be(false);
      });
      it("allows config to be overridden from constructor", function() {
        var root_path;
        root_path = "/public/grassroots/";
        beats = new BeatsData("", {
          beat_root_path: root_path
        });
        return expect(beats.config("beat_root_path")).to.be(root_path);
      });
      return it("allows config to be overridden after construction", function() {
        var root_path;
        root_path = "/public/grassroots/";
        beats = new BeatsData();
        expect(beats.config("beat_root_path")).not.to.be(root_path);
        beats.config("beat_root_path", root_path);
        return expect(beats.config("beat_root_path")).to.be(root_path);
      });
    });
    describe("#process chunk", function() {
      before(function() {
        return beats = new BeatsData(beats_data_raw);
      });
      it("properly read data keys", function() {
        return expect(beats._data_keys.length).to.be(data_keys_in_raw.length);
      });
      it("properly imported raw beats", function() {
        expect(beats.processing_block).to.be(-1);
        return expect(beats._all_beats.length).to.be(num_beats_in_raw_data);
      });
      it("properly imported collections", function() {
        return expect(beats.get_blocks("collection").length).to.be(num_collections_in_raw_data);
      });
      return it("properly imported refs", function() {
        return expect(_.keys(beats._beat_refs).length).to.be(num_beats_in_raw_data);
      });
    });
    describe("#get_blocks", function() {
      before(function() {
        return beats = new BeatsData(beats_data_raw);
      });
      it("should return all blocks by default", function() {
        return expect(beats.get_blocks().length).to.be(2);
      });
      return it("should return blocks by type when specified", function() {
        return expect(beats.get_blocks("collection").length).to.be(num_collections_in_raw_data);
      });
    });
    describe("#get_beat_from_ref", function() {
      before(function() {
        return beats = new BeatsData(beats_data_raw);
      });
      it("should return a beat by ref", function() {
        var beat;
        beat = beats.get_beat_from_ref("$morningbeat011816");
        return expect(beat.title).to.be("Morning beat 01/18/16");
      });
      return it("should return false for a bad ref", function() {
        var beat;
        beat = beats.get_beat_from_ref("$hotsaucecommittee");
        return expect(beat).to.be(false);
      });
    });
    describe("#process_line", function() {
      before(function() {
        return beats = new BeatsData("");
      });
      it("should start a collection block", function() {
        expect(beats.processing_block).not.to.be("collection");
        beats.process_line("collection do name: Handsome beats");
        return expect(beats.processing_block).to.be("collection");
      });
      it("should end a block with 'end'", function() {
        beats.process_line("collection do name: Handsome beats");
        expect(beats.processing_block).not.to.be(0);
        beats.process_line("end");
        return expect(beats.processing_block).to.be(0);
      });
      it("should store a beat and ref", function() {
        beats._all_beats = [];
        beats.process_line("$coolbeat, coolbeat.wav, Cool beat");
        expect(beats._all_beats.length).to.be(1);
        return expect(_.keys(beats._beat_refs).length).to.be(1);
      });
      return it("should add a beat to a collection when processing a collection", function() {
        beats.store_beat("$coolbeat2, coolbeat2.wav, Cool beat 2");
        beats.start_block("collection", "name: Cool beats");
        expect(beats.this_block_meta.beat_refs.length).to.be(0);
        beats.process_line("$coolbeat2");
        return expect(beats.this_block_meta.beat_refs.length).to.be(1);
      });
    });
    describe("#store_data_keys", function() {
      before(function() {
        return beats = new BeatsData();
      });
      it("should store data keys from a comma separated line", function() {
        beats.store_data_keys("one, two, three and change");
        return expect(beats._data_keys.length).to.be(3);
      });
      return it("should store data keys when given an array of keys", function() {
        beats.store_data_keys(["one", "two"]);
        return expect(beats._data_keys.length).to.be(2);
      });
    });
    describe("#default_beat_data_clone", function() {
      beforeEach(function() {
        return beats = new BeatsData();
      });
      it("should return some defaults", function() {
        var clone;
        clone = beats.default_beat_data_clone();
        return expect(_.keys(clone).toString()).to.equal(["file_path", "title", "collection", "version", "created_on", "updated_on", "tags"].toString());
      });
      it("should append any data keys that are not defaults", function() {
        var clone;
        beats._data_keys = ["big_money"];
        clone = beats.default_beat_data_clone();
        return expect(_.keys(clone)).to.contain("big_money");
      });
      return it("should cache the defaults when called multiple times", function() {
        expect(beats._beat_data_defaults != null).to.be(false);
        beats.default_beat_data_clone();
        return expect(beats._beat_data_defaults != null).to.be(true);
      });
    });
    describe("#start_block", function() {
      beforeEach(function() {
        return beats = new BeatsData();
      });
      it("should store the type as meta info when starting a block", function() {
        var block_type;
        block_type = "fhgwhghad";
        beats.start_block(block_type);
        return expect(beats.this_block_meta.type).to.be(block_type);
      });
      it("should begin processing a block when requested", function() {
        beats.start_block("collection", "name: processed beats");
        return expect(beats.processing_block).to.be("collection");
      });
      it("should set default meta data when starting a known block type", function() {
        beats.start_block("collection");
        return expect(_.keys(beats.this_block_meta).toString()).to.be(["name", "dir", "hide", "beat_refs", "type"].toString());
      });
      it("should only set type when starting an unknown block type", function() {
        beats.start_block("camping");
        return expect(_.keys(beats.this_block_meta).toString()).to.be(["type"].toString());
      });
      it("should accept custom values in the block opening line", function() {
        beats.start_block("collection", "dir: camping_beats/");
        return expect(beats.this_block_meta.dir).to.be("camping_beats/");
      });
      return it("should accept custom keys with custom values in the block opening", function() {
        beats.start_block("collection", "name: Bangin beats, all_bangers: yup");
        expect(beats.this_block_meta.name).to.be("Bangin beats");
        expect(_.keys(beats.this_block_meta)).to.contain("all_bangers");
        return expect(beats.this_block_meta.all_bangers).to.be("yup");
      });
    });
    describe("#end_block", function() {
      before(function() {
        return beats = new BeatsData();
      });
      it("should reset processing_block", function() {
        beats.processing_block = 100;
        beats.this_block_meta = {
          type: 100
        };
        beats.end_block();
        return expect(beats.processing_block).to.be(0);
      });
      return it("should add block data to blocks", function() {
        var test_meta;
        test_meta = {
          its: "me"
        };
        beats.blocks = [];
        beats.this_block_meta = test_meta;
        beats.end_block();
        return expect(beats.blocks[0].toString()).to.equal(test_meta.toString());
      });
    });
    return describe("#store_beat", function() {
      var beat_line_a, beat_line_b, beat_line_c, data_keys;
      data_keys = "file_path, title, collection, tags, version, created_on, last_updated_on";
      beat_line_a = "$whipped, whipped_4.wav, Whipped, Kitchen Beats";
      beat_line_b = "$whipped, whipped_4.wav, Whipped, Kitchen Beats, [cook, whip, kitchen], 4, 01/03/16, 01/06/16";
      beat_line_c = "$whipped, whipped_4.wav, Whipped";
      beforeEach(function() {
        beats = new BeatsData();
        return beats.store_data_keys(data_keys);
      });
      it("should add new beats to _all_beats", function() {
        beats.store_beat(beat_line_a);
        return expect(beats._all_beats[0].title).to.be("Whipped");
      });
      it("should store a ref for a new beat", function() {
        beats.store_beat(beat_line_a);
        return expect(_.keys(beats._beat_refs)[0]).to.be("$whipped");
      });
      it("should assign the collection automatically when processing a collection", function() {
        var beat;
        beats.start_block("collection", "name: Kitchen Collection");
        beat = beats.store_beat(beat_line_c);
        return expect(beat.collection).to.be("Kitchen Collection");
      });
      it("should store the beat_ref on the collection when processing a collection", function() {
        var beat;
        beats.start_block("collection", "name: Kitchen Collection");
        beat = beats.store_beat(beat_line_c);
        return expect(beats.this_block_meta.beat_refs).to.contain("$whipped");
      });
      it("should append the s3 path to a beat source when configured to use s3", function() {
        var beat, test_s3_path;
        test_s3_path = "http://testing_s3_path/";
        beats.config("use_s3", true);
        beats.config("s3_path", test_s3_path);
        beat = beats.store_beat(beat_line_a);
        return expect(beat.source.indexOf(test_s3_path)).to.be(0);
      });
      it("should append the base dir to a beat source when configured not to use s3", function() {
        var beat, test_dir;
        test_dir = "/testing_dir/";
        beats.config("use_s3", false);
        beats.config("beat_root_path", test_dir);
        beat = beats.store_beat(beat_line_a);
        return expect(beat.source.indexOf(test_dir)).to.be(0);
      });
      return it("should know how to parse tags in to an array", function() {
        var beat, tags;
        beat = beats.store_beat(beat_line_b);
        tags = ["cook", "whip", "kitchen"];
        expect(beat.tags).to.be.an(Array);
        expect(beat.tags.length).to.be(tags.length);
        return expect(beat.tags.toString()).to.be(tags.toString());
      });
    });
  });

  describe("BeatLab.Query", function() {
    var beats_data, beats_data_raw, num_beats, query;
    beats_data_raw = "---\nfile_path, title, tags\n$morningbeat111115, 01 morningbeat111115_5.wav, Morning Beat 11/11/15, [chill, unmastered]\n$morningbeat112515, 02 morningbeat112515_3.wav, Morning Beat 11/25/15, [chill, hop hop, instrumental]\n$morningbeat120115, 03 morningbeat120115_4.wav, Morning Beat 12/01/15, [instrumental]\ncollection do name: soft beats\n  $morningbeat011516, morningbeat011516_4.wav, Morning beat 01/15/16, [freestyle, instrumental, samples]\n  $morningbeat011816, morningbeat011816_3.wav, Morning beat 01/18/16, [scary, themed]\nend";
    beats_data = new BeatsData(beats_data_raw);
    query = new BeatLab.Query(beats_data);
    num_beats = 5;
    describe("#get_beats", function() {
      it("returns all beats when invoked without params", function() {
        var beats;
        beats = query.get_beats();
        return expect(beats.length).to.be(num_beats);
      });
      it("returns all beats with a given tag", function() {
        var beats;
        beats = query.get_beats({
          tags: ["chill"]
        });
        return expect(beats.length).to.be(2);
      });
      return it("returns all beats matching any tag", function() {
        var beats;
        beats = query.get_beats({
          tags: ["chill", "instrumental"]
        });
        return expect(beats.length).to.be(4);
      });
    });
    describe("#get_all_beats", function() {
      return it("returns all beats", function() {
        var beats;
        beats = query.get_all_beats();
        return expect(beats.length).to.be(num_beats);
      });
    });
    describe("#get_beats_tagged", function() {
      it("returns the beats with the matching tag", function() {
        var beats;
        beats = query.get_beats_tagged(["chill"]);
        return expect(beats.length).to.be(2);
      });
      it("requires all tags to match when flagged match_all", function() {
        var beats;
        beats = query.get_beats_tagged(["chill", "instrumental"], true);
        return expect(beats.length).to.be(1);
      });
      it("can tag a string as the tag param", function() {
        var beats;
        beats = query.get_beats_tagged("chill");
        return expect(beats.length).to.be(2);
      });
      return it("returns an empty array when there are no matches", function() {
        var beats;
        beats = query.get_beats_tagged("1996");
        return expect(beats.length).to.be(0);
      });
    });
    describe("#get_beats_for_collection", function() {
      it("should return the beats in the collection", function() {
        var beats;
        beats = query.get_beats_for_collection("soft beats");
        return expect(beats.length).to.be(2);
      });
      return it("should return an empty array for collections that don't exist", function() {
        var beats;
        beats = query.get_beats_for_collection("buttery beats");
        return expect(beats.length).to.be(0);
      });
    });
    return describe("#get_collection", function() {
      it("should return the collection object without beats", function() {
        var coll, coll_keys;
        coll = query.get_collection("soft beats");
        coll_keys = _.keys(coll);
        expect(coll_keys).to.contain("beat_refs");
        return expect(coll_keys).to.not.contain("beats");
      });
      return it("should include the beats when requested", function() {
        var coll, coll_keys;
        coll = query.get_collection("soft beats", true);
        coll_keys = _.keys(coll);
        expect(coll_keys).to.contain("beats");
        return expect(coll.beats.length).to.be(2);
      });
    });
  });

}).call(this);
