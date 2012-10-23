# trigger to remove the chat
window.onbeforeunload = ->
  $(document).trigger("disconnect")
  return

Chat =
  connection: null
  user_name: null
  last_status: null
  domain: null
  login: null
  password: null
  bbb_room_url: null
  requester_name: null
  list_of_pending_contacts: []

  jid_to_id: (jid) ->
    Strophe.getBareJidFromJid(jid).replace(/@/,"-").replace(/\./g, "-")

  on_roster: (iq) ->
    $(iq).find('item').each (index, element) =>
      jid = $(element).attr 'jid'
      name = $(element).attr('name') or jid
      jid_id = Chat.jid_to_id jid
      subs = $(element).attr 'subscription'
      ask = $(element).attr 'ask'
      if subs  is "none" and not ask
        iq = $iq({type: "set"}).c("query", {xmlns: "jabber:iq:roster"}).c("item", {jid: jid, subscription: "remove"})
        Chat.connection.sendIQ iq

      contact = $("<li id='" + jid_id + "' class='offline'><div class='roster-contact'>" +
        "<div class='roster-name'>" + name + "</div><div class='roster-jid hidden'>" + jid +
         "</div></div></li>")

      Chat.insert_contact contact
      return

    Chat.connection.addHandler Chat.on_presence, null, "presence"
    Chat.connection.addHandler Chat.on_subscription_request, null, "presence", "subscribe"
    Chat.connection.addHandler Chat.on_unsubscribed_request, null, "presence", "unsubscribed"

    Chat.connection.send $pres()
    return true

  on_unsubscribed_request: (unsubscribed) ->
    from = $(unsubscribed).attr 'from'

    iq = $iq({type: "set"}).c("query", {xmlns: "jabber:iq:roster"}).c("item", {jid: from, subscription: "remove"})
    Chat.connection.sendIQ iq
    return true

  on_subscription_request: (subscription) ->
    from = $(subscription).attr 'from'
    jid_id = Chat.jid_to_id from

    if $("#" + jid_id).length > 0
      Chat.connection.send $pres({to: from, "type": "subscribed"})
    else
      iq = $iq({to: from, type: "get"}).c("vcard", {xmlns: "vcard-temp"})
      Chat.connection.sendIQ iq, Chat.on_vcard_temp
    return true

  on_presence: (presence) ->
    ptype = $(presence).attr 'type'
    if ptype isnt "subscribe" and ptype isnt "subscribed" and ptype isnt "unsubscribed"
      from = $(presence).attr 'from'
      jid_id = Chat.jid_to_id from

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
              if show is "away"
                contact.addClass "away"
                $("#chat-"+jid_id+" .none").addClass "away"

      Chat.insert_contact contact

      jid_id = Chat.jid_to_id from
      $("#chat-" + jid_id).data "jid", Strophe.getBareJidFromJid from
    return true

  on_vcard_temp: (iq) ->
    name_vcard = null
    from = $(iq).attr 'from'
    $(iq).find('FN').each (index, element) ->
      name_vcard = $(element).text()
      Chat.list_of_pending_contacts.push {name: name_vcard,jid:from}
    $(document).trigger('pending_requests')
    return true

  on_roster_changed: (iq) ->
    $(iq).find('item').each (index, element) ->
      sub = $(element).attr 'subscription'
      jid = $(element).attr 'jid'
      jid_id = Chat.jid_to_id jid
      name_jid = $(element).attr('name') or jid
      if $('#' + jid_id).length > 0 and $('#' + jid_id).find('.roster-name').text() isnt jid
        name = $('#' + jid_id).find('.roster-name').text()

      if sub is 'remove'
        $('#' + jid_id).remove()
      else
        contact_html = "<li id='" + jid_id + "' class='" +
          ($('#' + jid_id).attr('class') or "offline") +
          "'>" + "<div class='roster-contact'>" +
          "<div class='roster-name'>" + (name or name_jid) +
          "</div><div class='roster-jid hidden'>" + jid +
          "</div></div></li>"

        if $('#' + jid_id).length > 0
          $('#' + jid_id).replaceWith contact_html
        else
          Chat.insert_contact $(contact_html)
    return true

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
      Chat.scroll_chat jid_id

    else
      composing = $(message).find 'composing'
      if composing.length > 0
        if $('#chat-' + jid_id).size()
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
        unless $('#chat-' + jid_id).size()
          Chat.insertChatArea jid, jid_id, status, name

        $('#chat-' + jid_id + ' #content-chat').show()
        $('#chat-' + jid_id + ' .chat-input').focus()

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

  presence_value: (elem) ->
    if elem.hasClass 'online' then 3 else
      if elem.hasClass 'dnd' then  2 else
        if elem.hasClass 'away' then 1 else
          if elem.hasClass 'offline' then 0

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
          return false
        else
          if pres is cmp_pres
            if jid < cmp_jid
              $(element).before elem
              inserted = true
              return false

      if not inserted then $('#roster-area ul').append elem
    else
      $('#roster-area ul').append elem

  insertChatArea: (jid,jid_id,status,name) ->
    $("#chat-bar").append(
      "<div id='contact-chat' class='chat-align' style='width: 230px; height: 100%;'><div><div class='no-show' style='width: 225px; height: 100%; position: absolute;'>" +
      "<div id='chat-" + jid_id + "' class='chat-area' style='position: absolute;'>" + "<div class='chat-area-title'><h3><ul><li class='none " + status + "'><span class='ellipsis'>" + name +
      "</span><img id='close-chat' src='/assets/chat/icons/close-chat.png' width='12' height='12' /></li></ul></h3></div>" +
      "<div id='content-chat'><div style='border-bottom: solid 1px #DDD'><img id='bbb-chat-" + jid_id + "' src='/assets/icons/webcam.png' class='bbb-chat-icon'/></div>" +
      "<div id='message-area'><div class='chat-messages' style='word-wrap: break-word;'></div><textarea class='chat-input'></textarea></div></div></div></div></div></div>")

    $('#chat-' + jid_id).data 'jid', jid
    $('#chat-' + jid_id + ' .chat-input').autosize()
    iq = $iq({type: "get"})
      .c("list", {xmlns: "http://www.xmpp.org/extensions/xep-0136.html#ns", with: jid})
      .c("set", {xmlns: "http://jabber.org/protocol/rsm"})
      .c("max").t("100")
    Chat.connection.sendIQ iq, Chat.chat_history_list

  chat_history_list: (iq) ->
    iq1 = $iq({type: "get"})
      .c("retrieve", {xmlns: "http://www.xmpp.org/extensions/xep-0136.html#ns", with: $(iq).find("chat").last().attr("with"), start: $(iq).find("chat").last().attr("start")})
      .c("set", {xmlns: "http://jabber.org/protocol/rsm"})
      .c("max").t("100")
    Chat.connection.sendIQ iq1, Chat.chat_history

  chat_history: (iq) ->
    jid_id = Chat.jid_to_id $(iq).find("chat").attr("with")
    name = $("#"+jid_id).find(".roster-name").text()
    name_me = $("#status").text()
    $(iq).find("chat").children().each (index, element) =>
      if $(element).is("to")
        $("#chat-" + jid_id).find('.chat-messages').append(
          "<div class='chat-message'>" +
          "<span class='history-name'>" + name_me +
          " </span><span class='chat-text'>" + $(element).find("body").text() +
          "</span></div>")
        Chat.scroll_chat jid_id
      if $(element).is("from")
        $("#chat-" + jid_id).find('.chat-messages').append(
          "<div class='chat-message'>" +
          "<span class='history-name'>" + name +
          " </span><span class='chat-text'>" + $(element).find("body").text() +
          "</span></div>")
        Chat.scroll_chat jid_id

    $("#chat-" + jid_id).find('.chat-messages').append(
      "<div class='chat-message border-history'></div>")
    Chat.scroll_chat jid_id

#  creating_room: (iq) ->
#    console.log "sala"
#    console.log iq

$ ->
  # trigger to start the chat
  if chat_enabled? and chat_enabled
    $(document).trigger "connect",
      domain: domain
      login: login + domain
      password: cookie
      name: name
      url: url
      xmpp_server: xmpp_server

  $("#main-chat-area").on "click", "#main-chat #content-chat li#status", ->
    $("#status_list").toggle(0)
    $("#chat_status_"+Chat.last_status).removeClass "hidden"
    $("#chat_status_"+$("#status").attr('class')).addClass "hidden"
    Chat.last_status = $("#status").attr 'class'

  $("#main-chat-area").on "click", "#main-chat #content-chat li#status_list .chat_status", ->
    status = $(this).attr('class').replace "chat_status ",""
    $("#status").removeClass()
    $("#status-title").removeClass()
    $(document).trigger('change_status', {login: Chat.login, password: Chat.password, status: status, name: Chat.user_name, url: Chat.bbb_room_url, domain: Chat.domain})
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
    Chat.scroll_chat jid_id

  $("#main-chat-area").on 'click', ".chat-align .no-show #main-chat #content-chat #add_user", ->
    $.colorbox
      html:"<div class='modal-title'><span>" + I18n.t("chat.add")  + "</span></div><div class='modal-content'><label for='member_token'>" + I18n.t('chat.name.other') +
        "</label>" + "<input id='member_token' name='member_token' type='text' style='width:396px;' /><br>" +
        "<div id='chat_invite_button'><button id='submit' class='btm' type='submit'>" + I18n.t('chat.add') + "</button></div></div>"
      onComplete: ->
        jid = []
        name = []

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

        $('#member_token_tokeninput').focus()

        $(document).on "click", "#submit", ->
          if jid.length
            $(document).trigger 'contact_added', { jid: jid, name: name }
            jid = []
            name = []
            $.colorbox.close()

  $("#main-chat-area").on 'click', ".chat-align .no-show #main-chat #content-chat #bbb_invite", ->
    $.colorbox
      html:"<div class='modal-title'><span>" + I18n.t("chat.invite.bbb")  + "</span></div><div class='modal-content'><label for='member_token'>" + I18n.t('chat.name.other') +
        "</label>" + "<input id='member_token' name='member_token' type='text' style='width:396px;' /><br>" +
        "<div id='chat_invite_button'><button id='submit' class='btm' type='submit'>" + I18n.t('chat.invite.button') + "</button></div></div>"
      onComplete: ->
        jid = []

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
              domain_id = Chat.jid_to_id Chat.domain
              login = result[index-iten].id.replace(" ","-") + domain_id
              unless $("#" + login).hasClass "online"
                results.splice index-iten,1
                iten = iten + 1
            results

        $('#member_token_tokeninput').focus()

        $(document).on "click", "#submit", ->
          if jid.length
            $(document).trigger 'send_bbb', { jid: jid }
            $.colorbox.close()

  $("#main-chat-area").on 'click', ".chat-align .no-show #main-chat #content-chat #request_contacts", ->
    html = "<div class='modal-title'><span>" + I18n.t("chat.request.title")  + "</span></div><div class='modal-content'>"
    Chat.list_of_pending_contacts.forEach (element) ->
      html += "<div style='height:24px;'><span style=' line-height:24px;'>" + I18n.t("chat.request.body", {name: element.name}) + "</span><div id='contact_request_button' data-name='" +
        element.name + "' data-jid='" + element.jid + "' data-index='" + jQuery.inArray(element,Chat.list_of_pending_contacts) +
        "'><button id='approve' class='btm' type='submit'>" + I18n.t('chat.request.approve') +
        "</button><button id='deny' class='btm' type='submit' style='margin-left:3px;'>" + I18n.t('chat.request.deny') + "</button></div></div><br/>"
    html += "</div>"
    $.colorbox
      html: html
      onComplete: ->
        $(document).on "click", "#approve", ->
          name = $(this).parent().data('name')
          jid = $(this).parent().data('jid')
          iq = $iq({type: "set"}).c("query", {xmlns: "jabber:iq:roster"}).c("item", {jid: jid, name: name})
          Chat.connection.sendIQ iq
          Chat.connection.send $pres({to: jid, "type": "subscribe"})
          Chat.connection.send $pres({to: jid, "type": "subscribed"})
          Chat.list_of_pending_contacts.splice($(this).parent().data('index'),1)
          $(document).trigger('pending_requests')
          $.colorbox.close()

        $(document).on "click", "#deny", ->
          Chat.connection.send $pres({to: $(this).parent().data('jid'), "type": "unsubscribed"})
          Chat.list_of_pending_contacts.splice($(this).parent().data('index'),1)
          $(document).trigger('pending_requests')
          $.colorbox.close()

$(document).bind 'pending_requests', (ev) ->
  if Chat.list_of_pending_contacts.length > 0
    $("#request_contacts").removeClass "hidden"
    $("#request_contacts").empty().append ("<b>" + Chat.list_of_pending_contacts.length + "</b>")
  else
    $("#request_contacts").addClass "hidden"

$(document).bind 'connect', (ev, data) ->
  conn = new Strophe.Connection data.xmpp_server

  conn.connect data.login, data.password, (status) ->
    if status is Strophe.Status.CONNECTED
      Chat.xmpp_server = data.xmpp_server
      Chat.user_name = data.name
      Chat.domain = data.domain
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

$(document).bind 'connected', ->
  unless $("#main-chat").size()
    $("#chat-bar").append(
      "<div class='chat-align' style='width: 200px; height: 100%;'><div><div class='no-show' style='width: 195px; height: 100%; position: absolute;'>" +
      "<div id='main-chat' class='chat-area' style='position: absolute;'>" +
      "<div class='chat-area-title'><h3><ul><li id='status-title' class='none online'>" + I18n.t("chat.title")  + "</li></ul></h3></div>" +
      "<div id='content-chat'><div style='border-bottom: solid 1px #DDD;'>" +
      "<img id='add_user' src='/assets/icons/user_add.png' class='chat-menu-icon' style='cursor: pointer; cursor: hand;' title='Invite Users'/>" +
      "<img id='bbb_invite' src='/assets/icons/webcam_add.png' class='chat-menu-icon' style='cursor: pointer; cursor: hand;' title='Invite users to your BBB room'/>" +
      "<span id='request_contacts' class='contacts_circle hidden' style='cursor: pointer; cursor: hand;'></span>" +
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

  iq = $iq({type: "set"}).c("vcard", {xmlns: "vcard-temp"}).c("FN", Chat.user_name)
  Chat.connection.sendIQ iq

  Chat.connection.addHandler Chat.on_roster_changed, "jabber:iq:roster", "iq", "set"
  Chat.connection.addHandler Chat.on_message, null, "message", "chat"

  #iq = $iq({to: 'teste@conference.prav-chat.no-ip.org', type: 'get'}).c("query", {xmlns: "http://jabber.org/protocol/muc#owner"})
  #console.log "send owner request!"
  #console.log iq
  #Chat.connection.sendIQ iq, Chat.creating_room

$(document).bind 'disconnect', ->
  if Chat.connection
    $("#status-title").addClass "offline"
    $("#status").addClass "offline"
    $(document).trigger('change_status',{status: "offline"})

$(document).bind 'disconnected', ->
  Chat.connection = null
  Chat.list_of_pending_contacts = []

  $('#roster-area ul').empty()
  $('#roster-area').addClass "hidden"
  $('#request_contacts').addClass "hidden"
  $('#main-chat #content-chat').toggle(0)
  $('#chat-bar #contact-chat').remove()

$(document).bind 'contact_added', (ev,data) ->
  $.each data.jid, (index) ->
    found = false
    Chat.list_of_pending_contacts.forEach (element) ->
      if element.name is data.name[index]
        name = element.name
        jid = element.jid
        index = jQuery.inArray(element,Chat.list_of_pending_contacts)
        iq = $iq({type: "set"}).c("query", {xmlns: "jabber:iq:roster"}).c("item", {jid: jid, name: name})
        Chat.connection.sendIQ iq
        Chat.connection.send $pres({to: jid, "type": "subscribe"})
        Chat.connection.send $pres({to: jid, "type": "subscribed"})
        Chat.list_of_pending_contacts.splice(index,1)
        $(document).trigger('pending_requests')
        found = true
        return
    unless found
      jid = data.jid[index] + Chat.domain
      iq = $iq({type: "set"}).c("query", {xmlns: "jabber:iq:roster"}).c("item", {jid: jid,name:data.name[index]})
      Chat.connection.sendIQ iq
      subscribe = $pres({to: jid, "type": "subscribe"})
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
      $(document).trigger('connect',{login: data.login, password: data.password, name: data.name, url: data.url, domain: data.domain, xmpp_server: Chat.xmpp_server})
      $("#chat_status_dnd").removeClass "hidden"
      $("#chat_status_away").removeClass "hidden"
    else
      status = $pres().c('show').t data.status
      Chat.connection.send status

$(document).bind 'send_bbb', (ev,data) ->
  $(data.jid).each (index) ->
    name = $("#status").text()
    jid = data.jid[index] + Chat.domain

    body = I18n.t('chat.invite.msg_clean')
    body = body.replace /URL/g,Chat.bbb_room_url
    message = $msg({to: jid, "type": "chat", "bbb": "invite", "url": Chat.bbb_room_url})
      .c('body').t(body).up()
      .c('active', {xmlns: "http://jabber.org/protocol/chatstates"})

    Chat.connection.send message
