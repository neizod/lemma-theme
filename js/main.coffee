---
---

rightbar_change_visible = () ->
    $('#rightbar').is(':visible') != $('#rightbar').data('prev-visible')

rightbar_make_position = () ->
    $('#rightbar').data('prev-visible', $('#rightbar').is(':visible'))
    dest = if $('#rightbar').is(':visible') then '#rightbar' else '#leftbar'
    $('#menubar-movable').detach().appendTo(dest)


$(document).ready ->
    $('table').addClass('table')
    $('#menubar').addClass('hidden-xs')
    rightbar_make_position()

    $('img').each (_, img) ->
        alt = $(img).attr('alt')
        if alt?.trim().length
            $(img).wrap($('<div>').addClass('figure'))
                  .after($('<p>').html($('<em>').html(alt)))
                  .wrap('<p>')

    $('#menu-toggle').click ->
        $('#menubar').toggleClass('hidden-xs')

    $(window).resize ->
        if rightbar_change_visible()
            rightbar_make_position()
