class World.Home extends World.Widget
  before_setup: ->
    @overlay = $(".overlay").hide()
    @showcase = new Showcase @container.find("#showcase"), @opts
    @contact_form = @container.find "#contact-form"
    @contact_submit = @contact_form.find("input[type=submit]")

    for a in @container.find("a")
      $a = $ a
      if $a.attr('href').search(new RegExp('http(|s):\/\/')) > -1
        $a.attr('target', '_blank')

  setup_events: ->
    @dispatch "click", {
      submit_btn: (btn) =>
        @submit_contact_form()
    }

    @bind_key 13, (e) =>
      unless $(e.target).is("textarea")
        return @submit_contact_form()

      false

  reset_contact_form: ->
    @contact_form.find('.alert').fadeOut(300)
    @contact_form.find('input[type=text],textarea').val('')
    @contact_submit.val('Send').removeClass('disabled')

  contact_form_errors: (data) ->
    if _.isEmpty data.name
      "Name is required"
    else if _.isEmpty data.email
      "Email is required"
    else if _.isEmpty data.message
      "Message is required"
    else
      false

  submit_contact_form: ->
    return if @contact_submit.is(".disabled")

    @contact_submit.text("Sending...").addClass("disabled")

    data =
      name: @contact_form.find("input[name=name]").val()
      email: @contact_form.find("input[name=email]").val()
      message: @contact_form.find("textarea[name=message]").val()

    $alert = @container.find ".alert"

    done = (err, message) =>
      if err
        $alert.fadeIn()
          .removeClass('alert-success')
          .addClass('alert-error')
          .children('p')
            .text(message)

        @contact_submit.val('Try Again')
      else
        $alert.fadeIn()
          .removeClass('alert-error')
          .addClass('alert-success')
          .children('p')
            .text(message)

        setTimeout =>
          $alert.fadeOut 300
          @reset_contact_form()
        , 10000

      @contact_submit.removeClass("disabled")


    errors = @contact_form_errors data
    return done(true, errors) if errors

    @contact_submit.val('Sending...').addClass("disabled")
    @send_message data, (err, msg) =>
      done err, msg

  send_message: (data, fn=null) ->
    $.ajax
      type: "post"
      url: "/contact-submit"
      data: data
      dataType: "json"
      success: (msg) =>
        if msg.error
          fn? true, msg.message
        else
          fn? false, 'Message sent!'

