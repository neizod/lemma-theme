---
---

$(document).ready ->
    $('table').addClass('table')
    $('#menubar').addClass('hidden-xs')

    $('#menu-toggle').click ->
        $('#menubar').toggleClass('hidden-xs')
