---
---

make_recent_date = () ->
    for label in $('#recent-list span.label')
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

tag_sort = (button) ->
    if /freq$/.test($(button).attr('id'))
        ord = (selector) -> (Number) $(selector).find('.badge').html()
        cmp = (a, b) -> if ord(a) <= ord(b) then 1 else -1
    else
        ord = (selector) -> $(selector).find('a:first').html().toLowerCase()
        cmp = (a, b) -> if ord(a) > ord(b) then 1 else -1
    $('ul#tags').html((li for li in $('ul#tags > li').detach()).sort(cmp))

correct_fixed_position_width = () ->
    $('#leftbar').css('width', $('#leftbar-spacing').css('width'))
    $('#rightbar').css('width', $('#rightbar-spacing').css('width'))
    $('#rightbar').css('left', $('#rightbar-spacing').offset()['left'])

correct_badge_position = () ->
    for badge in $('ul li span.badge')
        parent = $(badge).parent()
        $(badge).detach().prependTo(parent)

wrap_img = () ->
    for img in $('img')
        alt = $(img).attr('alt')
        if alt?.trim().length
            $(img).wrap($('<div>').addClass('figure'))
                  .after($('<p>').html($('<em>').html(alt)))
                  .wrap('<p>')

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
        $('#roaming-nav-quick').detach().appendTo('#leftrow')
        $('#roaming-share').detach().appendTo('#rightrow')
        $('#roaming-attribution').detach().appendTo('#leftrow')
        $('#roaming-nav-prev').detach().prependTo('#rightrow')
        $('#roaming-nav-next').detach().appendTo('#rightrow')
    else if mode == 'sm'
        $('#roaming-nav-quick').detach().appendTo('#leftrow')
        $('#roaming-share').detach().appendTo('#leftrow')
        $('#roaming-attribution').detach().appendTo('#leftrow')
        $('#roaming-nav-prev').detach().prependTo('#quick-navrow')
        $('#roaming-nav-next').detach().appendTo('#quick-navrow')
    else
        $('#roaming-nav-quick').detach().appendTo('#rightrow')
        $('#roaming-share').detach().appendTo('#rightrow')
        $('#roaming-attribution').detach().appendTo('#rightrow')
        $('#roaming-nav-prev').detach().prependTo('#quick-navrow')
        $('#roaming-nav-next').detach().appendTo('#quick-navrow')

make_spacing = (mode) ->
    if mode == 'xs'
        $('#leftrow').toggleClass('hidden-xs') if $('#leftrow').is(':visible')
        $('#leftbar-spacing').height($('#leftbar').height())
        $('#rightbar-spacing').height($('#rightbar').height())


$(document).ready ->
    $('table').addClass('table')
    $('#leftrow').addClass('hidden-xs')
    $('ul ul').css('margin-bottom', 0)
    correct_fixed_position_width()
    correct_badge_position()
    make_recent_date()
    monitor_device_mode()
    wrap_img()


    $('.tag-sort').click (event) ->
        event.preventDefault()
        $('.tag-sort').removeClass('active')
        $(this).addClass('active')
        tag_sort(this)

    $('.list-toggle').click (event) ->
        event.preventDefault()
        list_toggle(this)
        correct_fixed_position_width()

    $('#menu-toggle').click (event) ->
        event.preventDefault()
        $('#leftrow').toggleClass('hidden-xs')

    $(window).resize ->
        correct_fixed_position_width()
        monitor_device_mode()
