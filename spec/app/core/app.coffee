app = null

test_app =
  configure: -> 1
  listen: -> 0
  get: -> 1
  post: -> 1

test_mongoose =
  connect: -> @connected = true

Requires.mongoose = test_mongoose

test_config = null

describe "App", ->
  before ->
    app = App.init
      app: test_app
      mongoose: test_mongoose

  describe "#setup", ->
    it "should be configured", ->
      expect(app.is_configured).to.equal(true)

    it "should attempt to connect mongoose", ->
      expect(app.mongoose.connected).to.equal(true)

    it "should be set up", ->
      expect(app.is_setup).to.equal(true)

  describe "#base_url", ->
    it "should return the root url when called with no parameters", ->
      expect(app.base_url(null, true)).to.equal("http://testingbaseurl.com/")

    it "should apped a URI when passed", ->
      expect(app.base_url("/hotsauce", true)).to.equal("http://testingbaseurl.com/hotsauce")

  describe "#conf", ->
    it "should lookup a value by key", ->
      expect(app.conf("meta_keywords")).to.equal("meta keywords value")

    it "should return false for a key that isn't found", ->
      expect(app.conf("jibberjabber")).to.equal(false)

    it "should return false by default", ->
      expect(app.conf()).to.equal(false)

