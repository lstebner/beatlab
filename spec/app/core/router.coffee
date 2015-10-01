test_router = null

# test_app = 
#   get: ->
#   post: ->

describe "App.Router", ->
  beforeEach ->
    test_router = new App.Router test_app

  describe "#constructor", ->
    it "should throw an error when no app is passed", ->
      fn = -> new App.Router()
      expect(fn).to.throwException(/app is required/)

  describe "#register", ->
    it "should store a route when registered", ->
      controller = new App.Controller()
      new_route = test_router.register "get", "/get_cake", controller, "cake"
      expect(new_route[1]).to.eql("/get_cake")

    it "should store a route as GET by default", ->
      controller = new App.Controller()
      new_route = test_router.register "get", "/get_cake", controller, "cake"
      expect(new_route[0]).to.eql("get")

    it "should store a route as POST when requested", ->
      controller = new App.Controller()
      new_route = test_router.register "post", "/eat_cake", controller, "eat_cake"
      expect(new_route[0]).to.eql("post")
      expect(new_route[1]).to.eql("/eat_cake")

  describe "#do_404", ->
    it "should set the status to 404", ->
      res =
        status: (@page_status) -> { send: -> }
      test_router.do_404 res
      expect(res.page_status).to.be(404)

  describe "#get", ->
    it "should register a new route as get", ->
      new_route = test_router.get "/whateverman", {}, "whateverman"
      expect(new_route[0]).to.be("get")
      expect(new_route[1]).to.be("/whateverman")

  describe "#post", ->
    it "should register a new route as post", ->
      new_route = test_router.post "/anchorman", {}, "anchorman"
      expect(new_route[0]).to.be("post")
      expect(new_route[1]).to.be("/anchorman")

