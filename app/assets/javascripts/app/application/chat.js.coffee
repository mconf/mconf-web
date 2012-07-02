Chat =
  connection: null
  user_name: null
  last_status: null
  login: null
  password: null
  bbb_room_url: null
  requester_name: null

  jid_to_id: (jid) ->
    Strophe.getBareJidFromJid(jid).replace(/@/,"-").replace(/\./g, "-")

  on_roster: (iq) ->
    $(iq).find('item').each (index, element) =>
      jid = $(element).attr('jid')
      name = $(element).attr('name') or jid
      jid_id = Chat.jid_to_id jid

      contact = $("<li id='" + jid_id + "' class='offline'><div class='roster-contact'>" +
        "<div class='roster-name'>" + name + "</div><div class='roster-jid hidden'>" + jid +
         "</div></div></li>")

      Chat.insert_contact contact
      return

    Chat.connection.addHandler Chat.on_presence, null, "presence"

    Chat.connection.send $pres()
    return

  pending_subscriber: null

  on_presence: (presence) ->
    ptype = $(presence).attr 'type'
    from = $(presence).attr 'from'
    jid_id = Chat.jid_to_id from
    bbb = $(presence).attr 'bbb'

    if bbb is "invite"
      name  = $("#" + jid_id).find(".roster-name").text()
      status = $("#" + jid_id).attr "class"

      unless $('#chat-' + jid_id).size()
        Chat.insertChatArea from, jid_id, status, name

      $('#chat-' + jid_id + ' #content-chat').show()
      $('#chat-' + jid_id + ' .chat-input').focus()

      name = $("#"+jid_id+" .roster-contact .roster-name").text()
      body = I18n.t('chat.invite.msg')
      body = body.replace(/URL/g,$(presence).attr 'url')

      $("#chat-"+jid_id).find('.chat-messages').append(
        "<div class='chat-message'>" +
        "<span class='chat-name'>" + name +
        " </span><span class='chat-text'>" + body +
        "</span></div>")

    if ptype is "subscribe"
      name = $(presence).attr "name"
      Chat.pending_subscriber = from
      Chat.requester_name = name
      $(document).trigger('approve_request', {name: name, pending_subscriber: from})

    if ptype is "subscribed"
      Chat.connection.send $pres({to: from, "type": "subscribed"})
    else
      if ptype isnt "error"
        contact = $('#roster-area #' + jid_id)
          .removeClass("online")
          .removeClass("dnd")
          .removeClass("away")
          .removeClass("offline")

        $("#chat-"+jid_id+" .none")
          .removeClass("online")
          .removeClass("dnd")
          .removeClass("away")
          .removeClass("offline")

        if ptype is 'unavailable'
          contact.addClass("offline")
          $("#chat-"+jid_id+" .none").addClass "offline"
        else
          show = $(presence).find("show").text()
          if show is "" or show is "chat" or show is "online"
            contact.addClass("online")
            $("#chat-"+jid_id+" .none").addClass "online"
          else
            if show is "dnd"
              contact.addClass "dnd"
              $("#chat-"+jid_id+" .none").addClass "dnd"
            else
              contact.addClass "away"
              $("#chat-"+jid_id+" .none").addClass "away"

      Chat.insert_contact contact

    jid_id = Chat.jid_to_id from
    $("#chat-" + jid_id).data "jid", Strophe.getBareJidFromJid from

  on_roster_changed: (iq) ->
    $(iq).find('item').each (index, element) ->
      sub = $(element).attr 'subscription'
      jid = $(element).attr 'jid'
      name = $(element).attr('name') or jid
      jid_id = Chat.jid_to_id jid

      if sub is 'remove'
        $('#' + jid_id).remove()
      else
        contact_html = "<li id='" + jid_id + "' class='" +
          ($('#' + jid_id).attr 'class' or "offline") +
          "'>" + "<div class='roster-contact'>" +
          "<div class='roster-name'>" + name +
          "</div><div class='roster-jid hidden'>" + jid +
          "</div></div></li>"

        if $('#' + jid_id).length > 0
          $('#' + jid_id).replaceWith contact_html
        else
          Chat.insert_contact $(contact_html)

  on_message: (message) ->
    full_jid = $(message).attr 'from'
    jid = Strophe.getBareJidFromJid full_jid
    jid_id = Chat.jid_to_id jid
    name = $("#"+jid_id).find(".roster-name").text()
    status = $("#" + jid_id).attr "class"
    bbb = $(message).attr 'bbb'

    if bbb is "invite"
      unless $('#chat-' + jid_id).size()
        Chat.insertChatArea jid, jid_id, status, name

      $('#chat-' + jid_id + ' #content-chat').show()
      $('#chat-' + jid_id + ' .chat-input').focus()

      name = $("#" + jid_id + " .roster-contact .roster-name").text()
      body = I18n.t('chat.invite.msg')
      body = body.replace /URL/g,$(message).attr 'url'

      $("#chat-" + jid_id).find('.chat-messages').append(
        "<div class='chat-message'>" +
        "<span class='chat-name'>" + name +
        " </span><span class='chat-text'>" + body +
        "</span></div>")

    else
      unless $('#chat-' + jid_id).size()
        Chat.insertChatArea jid, jid_id, status, name

      $('#chat-' + jid_id + ' #content-chat').show()
      $('#chat-' + jid_id + ' .chat-input').focus()

      composing = $(message).find 'composing'

      if composing.length > 0
        $('#chat-' + jid_id + ' #content-chat #message-area .chat-messages').append("<div class='chat-event'>" + name + " " + I18n.t("chat.typing") +  "</div>")
        Chat.scroll_chat jid_id

      body = $(message).find "html > body"

      if body.length == 0
        body = $(message).find 'body'
        if body.length > 0
          body = body.text()
        else
          body = null
      else
        body = body.contents()
        span = $("<span></span>")
        body.each (index, element) =>
          if document.importNode
            $(document.importNode(element, true)).appendTo(span)
          else
            span.append(element.xml);
        body = span

      if body?
        $('#chat-' + jid_id + ' #content-chat #message-area .chat-messages .chat-event').remove()
        $('#chat-' + jid_id + ' #content-chat #message-area .chat-messages').append(
          "<div class='chat-message'>" +
          "<span class='chat-name'>" + name +
          " </span><span class='chat-text'>" +
          "</span></div>")
        $('#chat-' + jid_id + ' .chat-message:last .chat-text').append body
        Chat.scroll_chat jid_id
    return true

  scroll_chat: (jid_id) ->
    div = $("#chat-" + jid_id + " .chat-messages").get 0
    if div? then div.scrollTop = div.scrollHeight
    return

  presence_value: (elem) ->
    if elem.hasClass 'online' then 3 else
      if elem.hasClass 'dnd' then  2 else
        if elem.hasClass 'away' then 1 else 0

  insert_contact: (elem) ->
    jid = elem.find('.roster-jid').text()
    pres = Chat.presence_value elem
    contacts = $('#roster-area li')

    if contacts.size() > 0
      inserted = false
      contacts.each (index, element) =>
        cmp_pres = Chat.presence_value $(element)
        cmp_jid = $(element).find('.roster-jid').text()

        if pres > cmp_pres
          $(element).before elem
          inserted = true
        else
          if pres is cmp_pres
            if jid < cmp_jid
              $(element).before elem
              inserted = true
        return

      if not inserted then $('#roster-area ul').append elem

    else $('#roster-area ul').append elem
    return


  insertChatArea: (jid,jid_id,status,name) ->
    $("#chat-bar").append(
      "<div id='contact-chat' class='chat-align' style='width: 230px; height: 100%;'><div><div class='no-show' style='width: 225px; height: 100%; position: absolute;'>" +
      "<div id='chat-" + jid_id + "' class='chat-area' style='position: absolute;'>" + "<div class='chat-area-title'><h3><ul><li class='none " + status + "'>" + name +
      "<img id='close-chat' src='/assets/icons/close-chat.png' width='12' height='12' style='margin-top: 3.5px; margin-right: 5px; float: right; display:inline;' /></li></ul></h3></div>" +
      "<div id='content-chat'><div style='border-bottom: solid 1px #DDD'><img id='bbb-chat-" + jid_id + "' src='/assets/icons/bbb_logo.png' class='bbb-chat-icon'/></div></br>" +
      "<div id='message-area'><div class='chat-messages' style='word-wrap: break-word;'></div><textarea class='chat-input'></textarea></div></div></div></div></div></div>")

    $('#chat-' + jid_id).data 'jid', jid
    $('#chat-' + jid_id + ' .chat-input').autosize()
    return

$ ->

  $("#main-chat-area").on "click", "#main-chat #content-chat li#status", ->
    $("#status_list").toggle(0)
    $("#chat_status_"+Chat.last_status).removeClass "hidden"
    $("#chat_status_"+$("#status").attr('class')).addClass "hidden"
    Chat.last_status = $("#status").attr 'class'

  $("#main-chat-area").on "click", "#main-chat #content-chat li#status_list .chat_status", ->
    status = $(this).attr('class').replace "chat_status ",""
    $("#status").removeClass()
    $("#status-title").removeClass()
    $(document).trigger('change_status', {login: Chat.login, password: Chat.password, status: status, name: Chat.user_name, url: Chat.bbb_room_url})
    $("#status-title").addClass status
    $("#status").addClass status
    $("#status_list").toggle(0)

  $("#main-chat-area").on "click", ".chat-area-title", ->
    $(this).parents().children("#content-chat").toggle()

  $("#main-chat-area").on "click", "#contact-chat .no-show .chat-area .chat-area-title #close-chat", ->
    $(this).parents("#contact-chat").remove()

  $("#main-chat-area").on "click", "#main-chat #content-chat .roster-contact", ->
    jid = $(this).find(".roster-jid").text()
    name = $(this).find(".roster-name").text()
    jid_id = Chat.jid_to_id jid
    status = $("#" + jid_id).attr "class"

    unless $('#chat-' + jid_id).size()
      Chat.insertChatArea jid, jid_id, status, name

    $('#chat-' + jid_id + ' #content-chat').show()
    $('#chat-' + jid_id + ' .chat-input').focus()
    return

  $("#main-chat-area").on "keypress", "#contact-chat .no-show .chat-area #content-chat #message-area .chat-input", (ev) ->
    jid = $(this).parent().parent().parent().data 'jid'
    name = $("#status").text()

    if ev.which is 13 and $(this).val().length > 0
      ev.preventDefault()
      body = $(this).val()
      message = $msg({to: jid, "type": "chat"})
        .c('body').t(body).up()
        .c('active', {xmlns: "http://jabber.org/protocol/chatstates"})

      Chat.connection.send message

      if $(this).parent().find('.chat-messages').find('.chat-event').size() > 0
        $(this).parent().find('.chat-messages').find('.chat-event').before(
          "<div class='chat-message'>" +
          "<span class='chat-name me'>" + name +
          " </span><span class='chat-text'>" +
          body +
          "</span></div>")
      else
        $(this).parent().find('.chat-messages').append(
          "<div class='chat-message'>" +
          "<span class='chat-name me'>" + name +
          " </span><span class='chat-text'>" +
          body +
          "</span></div>")

      Chat.scroll_chat Chat.jid_to_id jid

      $(this).val('')
      $(this).parent().data 'composing', false
      $(this).css "min-height","30px"
      $(this).css "max-height","30px"
      $(this).css "height","30px"

    else
      composing = $(this).parent().data 'composing'
      if not composing
        notify = $msg({to: jid, "type": "chat"})
          .c('composing', {xmlns: "http://jabber.org/protocol/chatstates"})
        Chat.connection.send notify

        $(this).parent().data 'composing', true

    return

  $("#main-chat-area").on "click", "#contact-chat .no-show .chat-area #content-chat .bbb-chat-icon", ->
    jid = $(this).parent().parent().parent().data 'jid'
    jid_id = Chat.jid_to_id jid
    name = $("#status").text()

    body = I18n.t('chat.invite.msg_clean')
    body = body.replace /URL/g,Chat.bbb_room_url
    message = $msg({to: jid, "type": "chat", "bbb": "invite", "url": Chat.bbb_room_url})
      .c('body').t(body).up()
      .c('active', {xmlns: "http://jabber.org/protocol/chatstates"})

    Chat.connection.send message

    body = I18n.t('chat.invite.msg_sender')
    body = body.replace /URL/g,Chat.bbb_room_url

    $("#chat-"+jid_id).find('.chat-messages').append(
      "<div class='chat-message'>" +
      "<span class='chat-name me'>" + name +
      " </span><span class='chat-text'>" + body +
      "</span></div>")

  $("#main-chat-area").on 'click', ".chat-align .no-show #main-chat #content-chat #add_user", ->
    $.colorbox
      html:"<div class='modal-title'><span>" + I18n.t("chat.add")  + "</span></div><div class='modal-content'><label for='member_token'>" + I18n.t('chat.name.other') +
        "</label>" + "<input id='member_token' name='member_token' type='text' style='width:396px;' /><br>" +
        "<div id='chat_invite_button'><button id='submit' class='btm' type='submit'>" + I18n.t('chat.add') + "</button></div></div>"
      onComplete: ->
        jid = new Array()
        name = new Array()

        $("#member_token").tokenInput '/users/select_users.json',
          crossDomain: false
          theme: 'facebook'
          preventDuplicates: true
          searchDelay: 200
          minChar: 2
          hintText: I18n.t("chat.invite.hint")
          onAdd: (item) ->
            jid.push item.id
            name.push item.name
          onDelete: (item) ->
            jid.splice jid.indexOf(item.id),1
            name.splice name.indexOf(item.name),1
          onResult: (result) ->
            results = result
            iten = 0
            $.each result, (index) ->
              if result[index]
                if result[index].name is Chat.user_name
                  results.splice index-iten,1
                  iten = iten + 1
            results

        $(document).on "click", "#submit", ->
          if jid.length
            $(document).trigger 'contact_added', { jid: jid, name: name }
            $.colorbox.close()

  $("#main-chat-area").on 'click', ".chat-align .no-show #main-chat #content-chat #bbb_invite", ->
    $.colorbox
      html:"<div class='modal-title'><span>" + I18n.t("chat.invite.bbb")  + "</span></div><div class='modal-content'><label for='member_token'>" + I18n.t('chat.name.other') +
        "</label>" + "<input id='member_token' name='member_token' type='text' style='width:396px;' /><br>" +
        "<div id='chat_invite_button'><button id='submit' class='btm' type='submit'>" + I18n.t('chat.invite.button') + "</button></div></div>"
      onComplete: ->
        jid = new Array()

        $("#member_token").tokenInput '/users/select_users.json',
          crossDomain: false
          theme: 'facebook'
          preventDuplicates: true
          searchDelay: 200
          hintText: I18n.t("chat.invite.hint")
          onAdd: (item) ->
            jid.push item.id
          onDelete: (item) ->
            jid.splice jid.indexOf(item.id),1
          onResult: (result) ->
            results = result
            iten =0
            $.each result, (index) ->
              login = result[index-iten].id.replace(" ","-") + "-chat-bottin-no-ip-info"
              unless $("#" + login).hasClass "online"
                results.splice index-iten,1
                iten = iten + 1
            results

        $(document).on "click", "#submit", ->
          if jid.length
            $(document).trigger 'send_bbb', { jid: jid }
            $.colorbox.close()

$(document).bind 'approve_request', (ev,data) ->
  $.colorbox
    html:"<div class='modal-title'><span>" + I18n.t("chat.request.title")  + "</span></div><div class='modal-content'>" + I18n.t("chat.request.body", {name: data.name})  +
      "<br><div id='chat_request_button'><button id='approve' class='btm' type='submit'>" + I18n.t('chat.request.approve') +
      "</button><button id='deny' class='btm' type='submit'>" + I18n.t('chat.request.deny') + "</button></div></div>"
    onComplete: ->
      $(document).on "click", "#approve", ->
        iq = $iq({type: "set"})
          .c("query", {xmlns: "jabber:iq:roster"})
          .c("item", { jid: data.pending_subscriber, name: data.name})
        Chat.connection.sendIQ iq
        Chat.connection.send $pres({to: data.pending_subscriber, "type": "subscribed"})
        Chat.pending_subscriber = null
        $.colorbox.close()

      $(document).on "click", "#deny", ->
        Chat.connection.send $pres({to: data.pending_subscriber, "type": "unsubscribed"})
        Chat.pending_subscriber = null
        $.colorbox.close()


$(document).bind 'connect', (ev, data) ->
  conn = new Strophe.Connection 'http://chat-bottin.no-ip.info:5280/http-bind'

  conn.connect data.login, data.password, (status) ->
    if status is Strophe.Status.CONNECTED
      Chat.user_name = data.name
      Chat.login = data.login
      Chat.password = data.password
      Chat.bbb_room_url = data.url
      $("#status").removeClass("offline").addClass "online"
      $(document).trigger 'connected'
    else
      if status is Strophe.Status.DISCONNECTED
        $(document).trigger 'disconnected'
    return
  Chat.connection = conn
  return

$(document).bind 'connected', ->
  unless $("#main-chat").size()
    $("#chat-bar").append(
      "<div class='chat-align' style='width: 200px; height: 100%;'><div><div class='no-show' style='width: 195px; height: 100%; position: absolute;'>" +
      "<div id='main-chat' class='chat-area' style='position: absolute;'>" +
      "<div class='chat-area-title'><h3><ul><li id='status-title' class='none online'>" + I18n.t("chat.title")  + "</li></ul></h3></div>" +
      "<div id='content-chat'><div style='border-bottom: solid 1px #DDD;'>" +
      "<img id='add_user' src='/assets/icons/user_add.png' class='chat-menu-icon' style='cursor: pointer; cursor: hand;' title='Invite Users'/>" +
      "<img id='bbb_invite' src='/assets/icons/bbb_logo.png' class='chat-menu-icon' style='cursor: pointer; cursor: hand;' title='Invite users to your BBB room'/>" +
      "</div><ul style='margin-top: 10px; margin-bottom: 0px;'>" +
      "<li id='status' class='online' style='margin-left: 5px; cursor: pointer; cursor: hand;'>" + Chat.user_name  + "</li>" +
      "<li id='status_list' class='none' style='display: none; margin-left: 5px;'><ul style='cursor: pointer; cursor: hand;'>" +
      "<li id='chat_status_online' class='chat_status online'>Online</li>" +
      "<li id='chat_status_dnd' class='chat_status dnd'>Do Not Disturb</li>" +
      "<li id='chat_status_away' class='chat_status away'>Away</li>" +
      "<li id='chat_status_offline' class='chat_status offline'>Offline</li>" +
      "</ul></li></ul>" +
      "<div id='roster-area'><ul style='cursor: pointer; cursor: hand;'></ul></div>" +
      "</div></div></div></div></div>")

  iq = $iq({type: 'get'}).c('query', {xmlns: 'jabber:iq:roster'})
  Chat.connection.sendIQ iq, Chat.on_roster

  Chat.connection.addHandler Chat.on_roster_changed, "jabber:iq:roster", "iq", "set"

  Chat.connection.addHandler Chat.on_message, null, "message", "chat"
  return

$(document).bind 'disconnect', ->
  if Chat.connection
    Chat.connection.disconnect()

$(document).bind 'disconnected', ->
  Chat.connection = null
  Chat.pending_subscriber = null

  $('#roster-area ul').empty()
  $('#roster-area').addClass "hidden"
  $('#main-chat #content-chat').toggle(0)
  $('#chat-bar #contact-chat').remove()
  return

$(document).bind 'contact_added', (ev,data) ->
  $.each data.jid, (index) ->
    jid = data.jid[index] + "@chat-bottin.no-ip.info"
    iq = $iq({type: "set"}).c("query", {xmlns: "jabber:iq:roster"}).c("item", {jid: jid, name:data.name[index]})
    Chat.connection.sendIQ iq
    subscribe = $pres({to: jid, "type": "subscribe", "name": Chat.user_name})
    Chat.connection.send subscribe

$(document).bind 'change_status', (ev,data) ->
  if data.status is "offline"
    Chat.connection.disconnect()
    Chat.last_status = null
    $("#chat_status_online").removeClass "hidden"
    $("#chat_status_dnd").addClass "hidden"
    $("#chat_status_away").addClass "hidden"
  else
    if data.status is "online" and not Chat.connection?
      $("#roster-area").removeClass()
      $(document).trigger('connect',{login: data.login, password: data.password, name: data.name, url: data.url})
      $("#chat_status_dnd").removeClass "hidden"
      $("#chat_status_away").removeClass "hidden"
    else
      status = $pres().c('show').t data.status
      Chat.connection.send status

$(document).bind 'send_bbb', (ev,data) ->
  $(data.jid).each (index) ->
    name = $("#status").text()
    jid = data.jid[index] + "@chat-bottin.no-ip.info"

    body = I18n.t('chat.invite.msg_clean')
    body = body.replace /URL/g,Chat.bbb_room_url
    message = $msg({to: jid, "type": "chat", "bbb": "invite", "url": Chat.bbb_room_url})
      .c('body').t(body).up()
      .c('active', {xmlns: "http://jabber.org/protocol/chatstates"})

    Chat.connection.send message