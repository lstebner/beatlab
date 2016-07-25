describe "BeatLab.Query", ->
  beats_data_raw = """
---
file_path, title, tags
$morningbeat111115, 01 morningbeat111115_5.wav, Morning Beat 11/11/15, [chill, unmastered]
$morningbeat112515, 02 morningbeat112515_3.wav, Morning Beat 11/25/15, [chill, hop hop, instrumental]
$morningbeat120115, 03 morningbeat120115_4.wav, Morning Beat 12/01/15, [instrumental]
collection do name: soft beats
  $morningbeat011516, morningbeat011516_4.wav, Morning beat 01/15/16, [freestyle, instrumental, samples]
  $morningbeat011816, morningbeat011816_3.wav, Morning beat 01/18/16, [scary, themed]
end
"""

  beats_data = new BeatsData beats_data_raw
  query = new BeatLab.Query beats_data
  num_beats = 5

  describe "#get_beats", ->
    it "returns all beats when invoked without params", ->
      beats = query.get_beats()
      expect(beats.length).to.be(num_beats)

    it "returns all beats with a given tag", ->
      beats = query.get_beats tags: ["chill"]
      expect(beats.length).to.be(2)

    it "returns all beats matching any tag", ->
      beats = query.get_beats tags: ["chill", "instrumental"]
      expect(beats.length).to.be(4)

  describe "#get_all_beats", ->
    it "returns all beats", ->
      beats = query.get_all_beats()
      expect(beats.length).to.be(num_beats)

  describe "#get_beats_tagged", ->
    it "returns the beats with the matching tag", ->
      beats = query.get_beats_tagged ["chill"]
      expect(beats.length).to.be(2)

    it "requires all tags to match when flagged match_all", ->
      beats = query.get_beats_tagged ["chill", "instrumental"], true
      expect(beats.length).to.be(1)

    it "can tag a string as the tag param", ->
      beats = query.get_beats_tagged "chill"
      expect(beats.length).to.be(2)

    it "returns an empty array when there are no matches", ->
      beats = query.get_beats_tagged "1996"
      expect(beats.length).to.be(0)

  describe "#get_beats_for_collection", ->
    it "should return the beats in the collection", ->
      beats = query.get_beats_for_collection "soft beats"
      expect(beats.length).to.be(2)

    it "should return an empty array for collections that don't exist", ->
      beats = query.get_beats_for_collection "buttery beats"
      expect(beats.length).to.be(0)

  describe "#get_collection", ->
    it "should return the collection object without beats", ->
      coll = query.get_collection "soft beats"
      coll_keys = _.keys(coll)
      expect(coll_keys).to.contain("beat_refs")
      expect(coll_keys).to.not.contain("beats")

    it "should include the beats when requested", ->
      coll = query.get_collection "soft beats", true
      coll_keys = _.keys(coll)
      expect(coll_keys).to.contain("beats")
      expect(coll.beats.length).to.be(2)

