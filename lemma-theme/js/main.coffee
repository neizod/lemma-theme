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
        ord = (selector) -> (Number) $(selector).find('.ord-freq').html()
        cmp = (a, b) -> if ord(a) <= ord(b) then 1 else -1
    else
        ord = (selector) -> $(selector).find('.ord-alph').html().toLowerCase()
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

list_toggle = (a) ->
    li = $(a).parent()
    li.find('i.fa:first').toggleClass('fa-plus-square')
    li.find('i.fa:first').toggleClass('fa-minus-square')
    li.find('ul:first').toggleClass('hidden')

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
        $('#roaming-pager').detach().appendTo('#leftrow')
        $('#roaming-share').detach().appendTo('#footer')
        $('#roaming-attribution').detach().appendTo('#leftrow')
        $('#roaming-pager-newer').detach().appendTo('#mini-pager-newer')
        $('#roaming-pager-older').detach().appendTo('#mini-pager-older')
    else if mode == 'sm'
        $('#roaming-pager').detach().appendTo('#leftrow')
        $('#roaming-share').detach().appendTo('#leftrow')
        $('#roaming-attribution').detach().appendTo('#leftrow')
        $('#roaming-pager-newer').detach().appendTo('#full-pager')
        $('#roaming-pager-older').detach().appendTo('#full-pager')
    else
        $('#roaming-pager').detach().appendTo('#rightrow')
        $('#roaming-share').detach().appendTo('#rightrow')
        $('#roaming-attribution').detach().appendTo('#rightrow')
        $('#roaming-pager-newer').detach().appendTo('#full-pager')
        $('#roaming-pager-older').detach().appendTo('#full-pager')

make_spacing = (mode) ->
    if mode == 'xs'
        $('#menu-toggle').click() if $('#leftrow').is(':visible')
        $('#leftbar-spacing').height($('#leftbar').outerHeight())
        $('#rightbar-spacing').height($('#rightbar').outerHeight())


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

    $('.list-toggle').click().children('ul').click -> false
    $('.list-toggle').click (event) ->
        event.preventDefault()
        list_toggle(this)
        correct_fixed_position_width()

    $('#menu-toggle').click (event) ->
        event.preventDefault()
        $(this).toggleClass('active')
        $('#leftrow').toggleClass('hidden-xs')

    $(window).resize ->
        correct_fixed_position_width()
        monitor_device_mode()
