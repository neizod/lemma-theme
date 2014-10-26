---
---

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
    rightbar_make_position()
    correct_fixed_position_width()
    correct_badge_position()

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
