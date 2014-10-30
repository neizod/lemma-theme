---
---

make_recent_date = () ->
    $('#recent-list span.label').each (_, label) ->
        seconds = (Date.now() - Date.parse($(label).data('date'))) / 1000
        day = Math.floor(seconds / 60 / 60 / 24)
        month = Math.floor(seconds / 60 / 60 / 24 / 30)
        year = Math.floor(seconds / 60 / 60 / 24 / 365)
        if year > 1
            sentence = "#{year} years ago"
        else if year == 1
            sentence = 'a year ago'
        else if month > 1
            sentence = "#{month} months ago"
        else if month == 1
            sentence = 'a month ago'
        else if day > 1
            sentence = "#{day} days ago"
        else if day == 1
            sentence = "yesterday"
        else
            sentence = "today"
        $(label).html(sentence)

correct_fixed_position_width = () ->
    $('#leftbar').css('width', $('#leftbar-spacing').css('width'))
    $('#rightbar').css('width', $('#rightbar-spacing').css('width'))
    $('#rightbar').css('left', $('#rightbar-spacing').offset()['left'])

correct_badge_position = () ->
    $('ul li span.badge').each (_, badge) ->
        parent = $(badge).parent()
        $(badge).detach().prependTo(parent)

list_toggle = (it) ->
    parent = $(it).parent()
    parent.find('span.glyphicon:first').toggleClass('glyphicon-chevron-down')
    parent.find('span.glyphicon:first').toggleClass('glyphicon-chevron-up')
    parent.find('ul:first').toggleClass('hidden')

check_change_mode = () ->
    for mode in ['xs', 'sm', 'md']
        break if $("#device-#{mode}").is(':visible')
    if $('#device-mode').data('mode') != mode
        $('#device-mode').data('mode', mode)
        return mode
    return null

monitor_device_mode = () ->
    mode = check_change_mode()
    if mode?
        make_roaming_menu(mode)
        make_spacing(mode)

make_roaming_menu = (mode) ->
    if mode == 'xs'
        $('#roaming-nav-quick').detach().appendTo('#rightbar')
        $('#roaming-share').detach().appendTo('#rightbar')
    else if mode == 'sm'
        $('#roaming-nav-quick').detach().appendTo('#menubar')
        $('#roaming-share').detach().appendTo('#menubar')
    else
        $('#roaming-nav-quick').detach().appendTo('#rightbar')
        $('#roaming-share').detach().appendTo('#rightbar')

make_spacing = (mode) ->
    if mode == 'xs'
        $('#menubar').toggleClass('hidden-xs') if $('#menubar').is(':visible')
        $('#leftbar-spacing').height($('#leftbar').height())
        $('#rightbar-spacing').height($('#rightbar').height())


$(document).ready ->
    $('table').addClass('table')
    $('#menubar').addClass('hidden-xs')
    $('ul ul').css('margin-bottom', 0)
    correct_fixed_position_width()
    correct_badge_position()
    make_recent_date()
    monitor_device_mode()

    $('img').each (_, img) ->
        alt = $(img).attr('alt')
        if alt?.trim().length
            $(img).wrap($('<div>').addClass('figure'))
                  .after($('<p>').html($('<em>').html(alt)))
                  .wrap('<p>')

    $('.list-toggle').click (event) ->
        event.preventDefault()
        list_toggle(this)

    $('#menu-toggle').click (event) ->
        event.preventDefault()
        $('#menubar').toggleClass('hidden-xs')

    $(window).resize ->
        correct_fixed_position_width()
        monitor_device_mode()
