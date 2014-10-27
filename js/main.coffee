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

rightbar_change_visible = () ->
    $('#rightbar').is(':visible') != $('#rightbar').data('prev-visible')

rightbar_make_position = () ->
    $('#rightbar').data('prev-visible', $('#rightbar').is(':visible'))
    dest = if $('#rightbar').is(':visible') then '#rightbar' else '#leftbar'
    $('#rightbar-movable').detach().appendTo(dest)


$(document).ready ->
    $('table').addClass('table')
    $('#menubar').addClass('hidden-xs')
    $('ul ul').css('margin-bottom', 0)
    rightbar_make_position()
    correct_fixed_position_width()
    correct_badge_position()
    make_recent_date()

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
        if rightbar_change_visible()
            rightbar_make_position()
