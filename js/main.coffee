---
---

$(document).ready ->
    $('table').addClass('table')
    $('#menubar').addClass('hidden-xs')

    $('img').each (_, img) ->
        alt = $(img).attr('alt')
        if alt?.trim().length
            $(img).wrap($('<div>').addClass('figure'))
                  .after($('<p>').html($('<em>').html(alt)))
                  .wrap('<p>')

    $('#menu-toggle').click ->
        $('#menubar').toggleClass('hidden-xs')
