Events = {}

class EventTracker
    constructor: (@debug=false) ->
        _gaq = [] if !_gaq?

        @setup_events()

    setup_events: ->
        $('body').on 'click', '[data-track-click-event]', (e) =>
            @event($(this).data('track-click-event'));

    track_event: (cat, action, value, other) ->
        track = ['_trackEvent'];

        if _.isArray(cat)
            for val in cat
                track.push val
        else
            if cat then track.push(cat)
            if action then track.push(action)
            if value then track.push(value)
            if other then track.push(other)

        _gaq.push(track)
        console.log(track) if @debug

    event: (key) ->
        return unless _.has Events, key
        @track_event Events[key]

$ ->
    World.event_tracker = new EventTracker(1)
