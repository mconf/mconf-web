# -*- coding: utf-8 -*-

class InvitesController < ApplicationController
  def index
  end

  def invite_room
    @room_name = params[:roomName]
    @room_url = params[:roomUrl]
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

    priv_msg = Hash.new
    priv_email = Hash.new
    priv_msg[:sender_id] = current_user.id
    priv_email[:sender_id] = current_user.id

    # message body
    body = t('invite.message', :sender => current_user.name, :name => params[:invite][:room_name],
             :invite_url => params[:invite][:room_url]).html_safe
    unless params[:invite][:message].empty?
      body << params[:invite][:message]
      priv_email[:body] = params[:invite][:message]
    end
    priv_msg[:body] = body

    priv_msg[:title] = t('invite.title')
    priv_email[:title] = t('invite.title')
    priv_email[:room_name] = params[:invite][:room_name]
    priv_email[:room_url] = params[:invite][:room_url]
    priv_email[:user_name] = current_user.name

    if params[:invite][:im_check] != "0"
      for receiver in params[:invite][:members_tokens].split(",")
        priv_msg[:receiver_id] = receiver
        private_message = PrivateMessage.new(priv_msg)
        if private_message.save
          @success_messages << private_message
          success = t('invite.invitation_successfully') << t('invite.user_private_msg')
        else
          error = t('invite.invitation_unsuccessfully') << t('invite.user_private_msg')
          @fail_messages << private_message
        end
      end
    end

    if params[:invite][:email_check] != "0"
      emailSended = true
      for receiver in params[:invite][:members_tokens].split(",")
        user = User.find(receiver)
        priv_email[:email_receiver] = user.email
        email_message = Notifier.webconference_invite_email(priv_email)
        if email_message.deliver
          if success.size == 0
            success = t('invite.invitation_successfully') << "<li>" << t('invite.user_private_email') << user.email << "</li>"
          else
            success << "<li>" << t('invite.user_private_email') << user.email
          end
        else
          if error.size == 0
            error = t('invite.invitation_unsuccessfully') << "<li>" << t('invite.user_private_email') << user.email << "</li>"
          else
            error << "<li>" << t('invite.user_private_email') << user.email
          end
          @fail_email << email_message
        end
      end
    end
    
    if params[:invite][:email_tokens].size != 0
      for receiver in params[:invite][:email_tokens].split(/;|,/)
        priv_email[:email_receiver] = receiver
        email_message = Notifier.webconference_invite_email(priv_email)
        if (receiver =~ /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i)
          if email_message.deliver
            if success.size == 0
              success = t('invite.invitation_successfully') << "<li>" << t('invite.email') << receiver << "</li>"
            else
              success << "<li>" <<  t('invite.email') << receiver << "</li>"
            end
          else
            if error.size == 0
              error = t('invite.invitation_unsuccessfully') << "<li>" <<  t('invite.email') << receiver << "</li>"
            else
              error << "<li>" <<  t('invite.email') << receiver << "</li>"
            end
            @fail_email << email_message
          end
        else
          if error.size == 0
            error = t('invite.invitation_unsuccessfully') << "<li>" <<  t('invite.email') << receiver << t('invite.wrong_formatted') << "</li>"
          else
            error << "<li>" <<  t('invite.email') << receiver << t('invite.wrong_formatted') << "</li>"
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

end
