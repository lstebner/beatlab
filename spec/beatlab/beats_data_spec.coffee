beats_data_raw = """
this is the test beats data
this line above the starting line is just
a big ole comment.
so do whatever here, it's just going to be


..ignored.

---
# ordered keys, not all are required but they must be in order
file_path, title, collection, tags, version, created_on, last_updated_on

$morningbeat111115, 01 morningbeat111115_5.wav, Morning Beat 11/11/15, [chill, unmastered]
$morningbeat112515, 02 morningbeat112515_3.wav, Morning Beat 11/25/15, [chill, hop hop, instrumental]
$morningbeat120115, 03 morningbeat120115_4.wav, Morning Beat 12/01/15, [instrumental]
$morningbeat011516, morningbeat011516_4.wav, Morning beat 01/15/16, [freestyle, instrumental, samples]
$morningbeat011816, morningbeat011816_3.wav, Morning beat 01/18/16, [scary, themed]

collection do name: Headhunters, dir: headhunters
  $morningbeat111115
  $morningbeat112515
  $morningbeat120115
end

collection do name: January beats
  $morningbeat011516
  $morningbeat011816
end
"""
data_keys_in_raw = ["file_path", "title", "collection", "tags", "version", "created_on", "last_updated_on"]
num_beats_in_raw_data = 5
num_collections_in_raw_data = 2
beats = null

describe "BeatsData", ->
  describe "#config", ->
    before ->
      beats = new BeatsData beats_data_raw

    it "creates a config by default", ->
      beats = new BeatsData()
      expect(_.isEmpty(beats._config)).to.be false

    it "allows config to be overridden from constructor", ->
      root_path = "/public/grassroots/"
      beats = new BeatsData "", beat_root_path: root_path
      expect(beats.config("beat_root_path")).to.be(root_path)

    it "allows config to be overridden after construction", ->
      root_path = "/public/grassroots/"
      beats = new BeatsData()
      expect(beats.config("beat_root_path")).not.to.be(root_path)
      beats.config("beat_root_path", root_path)
      expect(beats.config("beat_root_path")).to.be(root_path)

  describe "#process chunk", ->
    before ->
      beats = new BeatsData beats_data_raw

    it "properly read data keys", ->
      expect(beats._data_keys.length).to.be(data_keys_in_raw.length)

    it "properly imported raw beats", ->
      expect(beats.processing_block).to.be(-1)
      expect(beats._all_beats.length).to.be(num_beats_in_raw_data)

    it "properly imported collections", ->
      expect(beats.get_blocks("collection").length).to.be(num_collections_in_raw_data)

    it "properly imported refs", ->
      expect(_.keys(beats._beat_refs).length).to.be(num_beats_in_raw_data)

  describe "#get_blocks", ->
    before ->
      beats = new BeatsData beats_data_raw

    it "should return all blocks by default", ->
      expect(beats.get_blocks().length).to.be(2)

    it "should return blocks by type when specified", ->
      expect(beats.get_blocks("collection").length).to.be(num_collections_in_raw_data)

  describe "#get_beat_from_ref", ->
    before ->
      beats = new BeatsData beats_data_raw

    it "should return a beat by ref", ->
      beat = beats.get_beat_from_ref "$morningbeat011816"
      expect(beat.title).to.be("Morning beat 01/18/16")

    it "should return false for a bad ref", ->
      beat = beats.get_beat_from_ref("$hotsaucecommittee")
      expect(beat).to.be(false)

  describe "#process_line", ->
    before ->
      beats = new BeatsData ""

    it "should start a collection block", ->
      expect(beats.processing_block).not.to.be("collection")
      beats.process_line("collection do name: Handsome beats")
      expect(beats.processing_block).to.be("collection")

    it "should end a block with 'end'", ->
      beats.process_line("collection do name: Handsome beats")
      expect(beats.processing_block).not.to.be(0)
      beats.process_line("end")
      expect(beats.processing_block).to.be(0)

    it "should store a beat and ref", ->
      beats._all_beats = []
      beats.process_line("$coolbeat, coolbeat.wav, Cool beat")
      expect(beats._all_beats.length).to.be(1)
      expect(_.keys(beats._beat_refs).length).to.be(1)

    it "should add a beat to a collection when processing a collection", ->
      beats.store_beat("$coolbeat2, coolbeat2.wav, Cool beat 2") 
      beats.start_block("collection", "name: Cool beats")
      expect(beats.this_block_meta.beat_refs.length).to.be(0)
      beats.process_line("$coolbeat2")
      expect(beats.this_block_meta.beat_refs.length).to.be(1)

  describe "#store_data_keys", ->
    before ->
      beats = new BeatsData()

    it "should store data keys from a comma separated line", ->
      beats.store_data_keys("one, two, three and change")
      expect(beats._data_keys.length).to.be(3)

    it "should store data keys when given an array of keys", ->
      beats.store_data_keys(["one", "two"])
      expect(beats._data_keys.length).to.be(2)

  describe "#default_beat_data_clone", ->
    beforeEach ->
      beats = new BeatsData()

    it "should return some defaults", ->
      clone = beats.default_beat_data_clone()
      expect(_.keys(clone).toString()).to.equal(["file_path", "title", "collection", "version", "created_on", "updated_on", "tags"].toString())

    it "should append any data keys that are not defaults", ->
      beats._data_keys = ["big_money"]
      clone = beats.default_beat_data_clone()
      expect(_.keys(clone)).to.contain("big_money")

    it "should cache the defaults when called multiple times", ->
      expect(beats._beat_data_defaults?).to.be(false)
      beats.default_beat_data_clone()
      expect(beats._beat_data_defaults?).to.be(true)

  describe "#start_block", ->
    beforeEach ->
      beats = new BeatsData()

    it "should store the type as meta info when starting a block", ->
      block_type = "fhgwhghad"
      beats.start_block block_type
      expect(beats.this_block_meta.type).to.be(block_type)

    it "should begin processing a block when requested", ->
      beats.start_block "collection", "name: processed beats"
      expect(beats.processing_block).to.be("collection")

    it "should set default meta data when starting a known block type", ->
      beats.start_block "collection"
      expect(_.keys(beats.this_block_meta).toString()).to.be(["name", "dir", "hide", "beat_refs", "type"].toString())

    it "should only set type when starting an unknown block type", ->
      beats.start_block "camping"
      expect(_.keys(beats.this_block_meta).toString()).to.be(["type"].toString())

    it "should accept custom values in the block opening line", ->
      beats.start_block "collection", "dir: camping_beats/"
      expect(beats.this_block_meta.dir).to.be("camping_beats/")

    it "should accept custom keys with custom values in the block opening", ->
      beats.start_block "collection", "name: Bangin beats, all_bangers: yup"
      expect(beats.this_block_meta.name).to.be("Bangin beats")
      expect(_.keys(beats.this_block_meta)).to.contain("all_bangers")
      expect(beats.this_block_meta.all_bangers).to.be("yup")

  describe "#end_block", ->
    before ->
      beats = new BeatsData()

    it "should reset processing_block", ->
      beats.processing_block = 100
      beats.this_block_meta = { type: 100 }
      beats.end_block()
      expect(beats.processing_block).to.be(0)

    it "should add block data to blocks", ->
      test_meta = { its: "me" }
      beats.blocks = []
      beats.this_block_meta = test_meta
      beats.end_block()
      expect(beats.blocks[0].toString()).to.equal(test_meta.toString())

  describe "#store_beat", ->
    data_keys = "file_path, title, collection, tags, version, created_on, last_updated_on
"

    beat_line_a = "$whipped, whipped_4.wav, Whipped, Kitchen Beats"
    beat_line_b = "$whipped, whipped_4.wav, Whipped, Kitchen Beats, [cook, whip, kitchen], 4, 01/03/16, 01/06/16"
    beat_line_c = "$whipped, whipped_4.wav, Whipped"

    beforeEach ->
      beats = new BeatsData()
      beats.store_data_keys data_keys

    it "should add new beats to _all_beats", ->
      beats.store_beat beat_line_a
      expect(beats._all_beats[0].title).to.be("Whipped")

    it "should store a ref for a new beat", ->
      beats.store_beat beat_line_a
      expect(_.keys(beats._beat_refs)[0]).to.be("$whipped")

    it "should assign the collection automatically when processing a collection", ->
      beats.start_block "collection", "name: Kitchen Collection"
      beat = beats.store_beat beat_line_c
      expect(beat.collection).to.be("Kitchen Collection")

    it "should append the s3 path to a beat source when configured to use s3", ->
      test_s3_path = "http://testing_s3_path/"
      beats.config "use_s3", true
      beats.config "s3_path", test_s3_path
      beat = beats.store_beat beat_line_a
      expect(beat.source.indexOf(test_s3_path)).to.be(0)

    it "should append the base dir to a beat source when configured not to use s3", ->
      test_dir = "/testing_dir/"
      beats.config "use_s3", false
      beats.config "beat_root_path", test_dir
      beat = beats.store_beat beat_line_a
      expect(beat.source.indexOf(test_dir)).to.be(0)

    it "should know how to parse tags in to an array", ->
      beat = beats.store_beat beat_line_b
      tags = ["cook", "whip", "kitchen"]
      expect(beat.tags).to.be.an(Array)
      expect(beat.tags.length).to.be(tags.length)
      expect(beat.tags.toString()).to.be(tags.toString())
















