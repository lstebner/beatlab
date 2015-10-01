test_view = null

describe "App.View", ->
  beforeEach ->
    req =
      url: ""
    res = 
      render: (@view_to_render) ->
    app = {}
    test_view = new App.View {}, req, res, app

  it "should autogenerate a unique id", (done) ->
    id1 = test_view.auto_generate_id()
    setTimeout ->
      id2 = test_view.auto_generate_id()
      expect(id1.length).to.be.greaterThan(1)
      expect(id1).to.not.be(id2)
      done()
    , 5

  it "should be able to add to js_opts", ->
    expect(test_view.js_opts).to.not.have.key("plum")
    test_view.add_js_opts plum: "purple"
    expect(test_view.js_opts).to.have.key("plum")

  it "should set the view", ->
    test_view.set_view("blender")
    expect(test_view.view).to.be("blender")

  it "should be able to set some data", ->
    expect(test_view.data).to.not.have.key("mangos")
    test_view.set_data("mangos", 5)
    expect(test_view.data).to.have.key("mangos")
    expect(test_view.data.mangos).to.be(5)

  it "should be able to extend existing data", ->
    expect(test_view.data).to.not.have.keys("kiwi", "plantain")
    test_view.extend_data kiwi: true, plantain: true
    expect(test_view.data).to.have.keys("kiwi", "plantain")
    expect(test_view.data.kiwi).to.be(true)
    expect(test_view.data.plantain).to.be(true)

  it "should not contain a js_block by default", ->
    expect(test_view.js_block()).to.be(false)
