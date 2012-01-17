# -*- coding: utf-8 -*-

class InvitesController < ApplicationController
  def index
  end

  def invite_room
    @type = params[:type]

    if @type == "webconference"
      @room = BigbluebuttonRoom.find_by_param(params[:room])
    elsif @type == "event"
      @event = Event.find(params[:event])
    end

    tags = []
    members = Profile.where("full_name like ?", "%#{params[:q]}%").select(['full_name', 'id']).limit(10)
    members.each do |f|
      tags.push("id"=>f.id, "name"=>f.full_name)
    end

    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
      format.json { render :json => tags }
    end
  end

  def send_invite
    @success_messages = Array.new
    @fail_messages = Array.new
    @fail_user_email = Array.new
    @fail_email = Array.new

    success = ""
    error = ""

    if params[:invite][:type] == "webconference"

      priv_msg = Hash.new
      priv_email = Hash.new

      priv_msg[:sender_id] = current_user.id
      priv_email[:sender_id] = current_user.id

      # message body
      body = t('invite.message', :sender => current_user.name, :name => params[:invite][:room_name],
               :invite_url => params[:invite][:room_url], :message => params[:invite][:message]).html_safe
      unless params[:invite][:message].empty?
        priv_email[:body] = params[:invite][:message]
      end
      priv_msg[:body] = body

      priv_msg[:title] = t('invite.title')
      priv_email[:title] = t('invite.title')
      priv_email[:room_name] = params[:invite][:room_name]
      priv_email[:room_url] = params[:invite][:room_url]
      priv_email[:user_name] = current_user.name
      priv_email[:locale] = current_user.locale

      if params[:invite][:im_check] != "0"
        for receiver in params[:invite][:members_tokens].split(",")
          priv_msg[:receiver_id] = receiver
          private_message = PrivateMessage.new(priv_msg)
          if private_message.save
            @success_messages << private_message
            success = t('invite.invitation_successfully') << " " << t('invite.user_private_msg', :user => private_message.receiver.full_name)
          else
            error = t('invite.invitation_unsuccessfully') << " " << t('invite.user_private_msg', :user => private_message.receiver.full_name)
            @fail_messages << private_message
          end
        end
      end

      if params[:invite][:email_check] != "0"
        emailSended = true
        for receiver in params[:invite][:members_tokens].split(",")
          user = User.find(receiver)
          priv_email[:email_receiver] = user.email
          Notifier.delay.webconference_invite_email(priv_email)
          if success.size == 0
            success = t('invite.invitation_successfully') << " " << t('invite.email', :email => user.email)
          else
            success << ", " << t('invite.email', :email => user.email)
          end
        end
      end

      if params[:invite][:email_tokens].size != 0
        for receiver in params[:invite][:email_tokens].split(/;|,/)
          priv_email[:email_receiver] = receiver
          Notifier.delay.webconference_invite_email(priv_email)
          if (receiver =~ /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i)
            if success.size == 0
              success = t('invite.invitation_successfully') << " " << t('invite.email', :email => receiver)
            else
              success << ", " << t('invite.email', :email => receiver)
            end
          else
            if error.size == 0
              error = t('invite.invitation_unsuccessfully') << " " <<  t('invite.email', :email => receiver) << " " << t('invite.bad_format')
            else
              error << ", " <<  t('invite.email', :email => receiver) << " " << t('invite.wrong_formatted')
            end
          end
        end
      end
    end

    if params[:invite][:type] == "event"
      @event = Event.find(params[:invite][:event_id])

      msg = Hash.new
      msg[:sender_id] = current_user.id

      if params[:invite][:im_check] != "0"
        for receiver in params[:invite][:members_tokens].split(",")
          user = User.find(receiver)
          msg[:title] = t('event.invite_title', :username => current_user.full_name, :eventname => @event.name, :space => @event.space.name, :locale => user.locale).html_safe
          body = t('event.invite_message', :event_name => @event.name, :space => @event.space.name, :event_date => @event.start_date.strftime("%A %B %d at %H:%M:%S"), :event_url => space_event_url(@event.space,@event), :username => current_user.full_name, :useremail => current_user.email, :userorg => current_user.organization, :locale => user.locale).html_safe
          msg[:body] = body
          msg[:receiver_id] = receiver
          private_message = PrivateMessage.new(msg)

          if private_message.save
            @success_messages << private_message
            success = t('invite.invitation_successfully') << " " << t('invite.user_private_msg', :user => private_message.receiver.full_name)
          else
            error = t('invite.invitation_unsuccessfully') << " " << t('invite.user_private_msg', :user => private_message.receiver.full_name)
            @fail_messages << private_message
          end
        end
      end

      msg_email = Hash.new
      msg_email[:sender] = current_user
      msg_email[:event] = @event

      if params[:invite][:email_check] != "0"
        for receiver in params[:invite][:members_tokens].split(",")
          user = User.find(receiver)
          msg_email[:receiver] = user
          Notifier.delay.event_invitation_email(msg_email)

          if success.size == 0
            success = t('invite.invitation_successfully') << " " << t('invite.email', :email => user.email)
          else
            success << ", " << t('invite.email', :email => user.email)
          end
        end
      end


      if params[:invite][:email_tokens].size != 0
        for receiver in params[:invite][:email_tokens].split(/;|,/)
          msg[:title] = t('event.invite_title', :username => current_user.full_name, :eventname => @event.name, :space => @event.space.name, :locale => current_user.locale).html_safe
          body = t('event.invite_message', :event_name => @event.name, :space => @event.space.name, :event_date => @event.start_date.strftime("%A %B %d at %H:%M:%S"), :event_url => space_event_url(@event.space,@event), :username => current_user.full_name, :useremail => current_user.email, :userorg => current_user.organization, :locale => current_user.locale).html_safe
          msg[:body] = body
          msg[:email_receiver] = receiver
          msg[:locale] = current_user.locale
          Notifier.delay.event_email(msg)

          if (receiver =~ /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i)
            if success.size == 0
              success = t('invite.invitation_successfully') << " " << t('invite.email', :email => receiver)
            else
              success << ", " << t('invite.email', :email => receiver)
            end
          else
            if error.size == 0
              error = t('invite.invitation_unsuccessfully') << " " <<  t('invite.email', :email => receiver) << " " << t('invite.bad_format')
            else
              error << ", " <<  t('invite.email', :email => receiver) << " " << t('invite.wrong_formatted')
            end
          end
        end
      end
    end

    respond_to do |format|
      if @fail_messages.empty?
        if success.size != 0
          flash[:success] = success.html_safe
        end
        if error.size != 0
          flash[:error] = error.html_safe
        end
        format.html { redirect_to request.referer }
        format.xml  { render :xml => @success_messages, :status => :created, :location => @success_messages }
      else
        if success.size != 0
          flash[:success] = success.html_safe
        end
        if error.size != 0
          flash[:error] = error.html_safe
        end
        format.html { redirect_to request.referer }
        format.xml  { render :xml => @fail_messages.map{|m| m.errors}, :status => :unprocessable_entity }
      end
    end

  end

  def send_notification
    @event = Event.find(params[:event_id])

    msg = Hash.new

    msg[:sender] = current_user
    msg[:event] = @event

    @event.participants.each do |p|
      user = User.find(p.user_id)

      if user != current_user
        msg[:receiver] = user
        Notifier.delay.event_notification_email(msg)
      end
    end

    respond_to do |format|
      flash[:success] = t('event.notification_successfully')
      format.html { redirect_to request.referer }
    end
  end

end
