test_controller = null

test_req = 
  params: key1: 1, key2: 2
  query: key1: 1, key2: 2
  cookies: key1: 1, key2: 2
  body: key1: 1, key2: 2

test_res = 
  status: (@status) ->
  render: (@view_name, @view_data) ->
  redirect: (@redirect_status, @redirect_dest) ->
  json: (@json_data) ->


describe "App.Controller", ->
  beforeEach ->
    test_controller = new App.Controller(test_req, test_res)

  describe "#set_view", ->
    it "sets the view", ->
      test_controller.set_view("jibberjabber")
      expect(test_controller.view_to_render).to.equal("jibberjabber")

  describe "#do_404", ->
    before ->
      test_controller.do_404()

    it "sets status to 404", ->
      expect(test_res.status).to.equal(404)

    it "set the view to 404", ->
      expect(test_res.view_name).to.be("404")


  # these are all methods that allow retrieving a value by key
  check_values_in = ["param", "query", "cookie", "body"]

  for thing in check_values_in
    describe "##{thing}", ->
      it "returns false by default", ->
        expect(test_controller[thing]()).to.equal(false)

      it "returns false for an invalid key", ->
        expect(test_controller[thing]("hoozah")).to.equal(false)

      it "returns a param value by key", ->
        expect(test_controller[thing]("key1")).to.equal(1)

  describe "#redirect", ->
    it "should set the destination", ->
      test_controller.redirect "/somewhere_else"
      expect(test_res.redirect_dest).to.be("/somewhere_else")

    it "should set the status to 302 by default", ->
      test_controller.redirect "/blahblah"
      expect(test_res.redirect_status).to.be(302)

    it "should set the status to anything requested", ->
      test_controller.redirect "/blahblah", 404
      expect(test_res.redirect_status).to.be(404)

  describe "#requires", ->
    beforeEach ->
      pub_methods = ["pub_method1", "pub_method2", "pub_method3"]
      for m in pub_methods
        test_controller[m] = -> 1
      test_controller.public_methods = pub_methods

    it "should have no requirements by default", ->
      expect(test_controller.requirements_list).to.be.empty()

    it "should add requirements for 'all' by default", ->
      test_controller.requires("apples")
      for r in test_controller.requirements_list
        expect(r).to.contain("apples")

    it "should add requirements for the requested method only", ->
      test_controller.requires("apples")
      test_controller.requires("bananas", "pub_method1")
      expect(test_controller.requirements_list["pub_method1"]).to.contain("bananas")
      expect(test_controller.requirements_list["pub_method2"]).to.not.contain("bananas")

    it "should add requirements to only the methods requested", ->
      test_controller.requires("apples")
      test_controller.requires("oranges", { only: ["pub_method1", "pub_method2"] })
      expect(test_controller.requirements_list["pub_method1"]).to.contain("oranges")
      expect(test_controller.requirements_list["pub_method3"]).to.not.contain("oranges")

    it "should add requirements to all the methods except where requested", ->
      test_controller.requires("apples")
      test_controller.requires("strawberries", { except: ["pub_method1", "pub_method2"] })
      expect(test_controller.requirements_list["pub_method1"]).to.not.contain("strawberries")
      expect(test_controller.requirements_list["pub_method3"]).to.contain("strawberries")

  describe "#loaded", ->
    it "should add to loaded_items", ->
      expect(test_controller.loaded_items).to.not.contain("onions")
      test_controller.loaded "onions"
      expect(test_controller.loaded_items).to.contain("onions")

  describe "#has_needs_met", ->
    before ->
      test_controller.pina_colada = ->
      test_controller.load = (@load_needs) ->

    it "should be ok when there are no current needs", ->
      expect(test_controller.has_needs_met()).to.be.ok()

    it "should set current_needs for requested method", ->
      test_controller.requires(["pineapples", "coconuts"], "pina_colada")
      test_controller.preload "pina_colada"
      expect(test_controller.current_needs.join("")).to.be(["pineapples", "coconuts"].join(""))

      it "should have called load with needs list", ->
        expect(test_controller.load_needs).to.be("pineapples coconuts")

  describe "#preload", ->
    before ->
      test_controller.load =  (what) -> @loaded what
      test_controller.requires "watermelon", "testload"

    it "should be ok if a method has no requirements", ->
      expect(test_controller.preload("methodwithnorequirements")).to.be.ok()

    it "should load a missing requirement"
    it "should give up trying to load after timeout is reached if needs aren't met"
    it "should be able to load multiple items"

  describe "#json", ->
    it "should send json", ->
      test_controller.json({some:"obj"})
      expect(JSON.stringify(test_res.json_data)).to.be(JSON.stringify({some:"obj"}))

  describe "#render", ->
    it "should render the requested method by default", ->
      test_controller.requested_method = "onion_rings"
      result = test_controller.render()
      expect(result).to.be.ok()
      expect(test_controller.view_data.view).to.be("onion_rings")

    it "should render the view_to_render when set", ->
      test_controller.view_to_render = "pineapple_rings"
      result = test_controller.render()
      expect(result).to.be.ok()
      expect(test_controller.view_data.view).to.be("pineapple_rings")

    it "should render a requested view", ->
      result = test_controller.render("index")
      expect(result).to.be.ok()
      expect(test_controller.view_data.view).to.be("index")

    it "should not render when cancelled", ->
      test_controller.cancel_render = true
      result = test_controller.render("index")
      expect(result).to.be(false)

    it "should not render when there is no view class", ->
      test_controller.view_class = null
      result = test_controller.render("index")
      expect(result).to.be(false)










