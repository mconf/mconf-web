

class InvitesController < ApplicationController
  def index
  end
  
  def invite_room
    @room_name = params[:roomName]
    @room_url = params[:roomUrl]
    tags = []
    members = Profile.where("full_name like ?", "%#{params[:q]}%").select(['full_name', 'id'])
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
    @fail_email = Array.new
    
    priv_msg = Hash.new
    priv_email = Hash.new
    priv_msg[:sender_id] = current_user.id
    priv_email[:sender_id] = current_user.id
    
    
    #corrigir formatação do texto das mensagens privadas
    #inicio do texto
    
    priv_msg[:body] = "You have been invite by " << current_user.name << " to participated in this webconference: " 
    priv_msg[:body] << params[:invite][:room_name] << "<br><br>Click on this link or copy and paste on your 
    browser this url for access the conference: "
    priv_msg[:body] << params[:invite][:room_url]
    priv_msg[:body] << "<br><br>This is the message sended by " << current_user.name << " to you:<br><br>"
    
    if(params[:invite][:message].empty?)
      priv_msg[:body] << "Invite for Webconference."
      priv_email[:body] = "Invite for Webconference."
    else
      priv_msg[:body] << params[:invite][:message]
      priv_email[:body] = params[:invite][:message]
    end
    
    #fim do texto
    
    priv_msg[:title] = "Invite for webconference"
    priv_email[:title] = "Invite for webconference"
    priv_email[:email_sender] = current_user.email
    priv_email[:room_name] = params[:invite][:room_name]
    priv_email[:room_url] = params[:invite][:room_url]
    priv_email[:user_name] = current_user.name
    
    if params[:invite][:im_check] != "0"
      for receiver in params[:invite][:members_tokens].split(",")
        priv_msg[:receiver_id] = receiver
        private_message = PrivateMessage.new(priv_msg)
        if private_message.save
          @success_messages << private_message
        else
          @fail_messages << private_message
        end
      end
    end

    if params[:invite][:email_check] != "0"
      for receiver in params[:invite][:email_tokens].split(",")
        priv_email[:email_receiver] = receiver
        email_message = Notifier.webconference_invite_email(priv_email)
        if email_message.deliver
        else
          @fail_email << email_message
        end
      end
    end
    
    respond_to do |format|
      if params[:invite][:im_check] != "0"
        if @fail_messages.empty?        
          if params[:invite][:email_check] != "0"
            if @fail_email.empty?
              flash[:success] = t('message.created') << ", " << t('sendemail.created')
            else
              flash[:success] = t('message.created')
              flash[:error] = t('sendemail.error.created')
            end
          else
            flash[:success] = t('message.created')
          end
          
          format.html { redirect_to request.referer }
          format.xml  { render :xml => @success_messages, :status => :created, :location => @success_messages }
        else        
          if params[:invite][:email_check] != "0"
            if @fail_email.empty?
              flash[:error] = t('message.error.create')
              flash[:success] = t('sendemail.created')
            else
              flash[:error] = t('message.error.create') << ", " << t('sendemail.error.created')
            end
          else
            flash[:error] = t('message.error.create')
          end
          
          format.html { redirect_to request.referer }
          format.xml  { render :xml => @fail_messages.map{|m| m.errors}, :status => :unprocessable_entity }
        end
      else
        if params[:invite][:email_check] != "0"
          if @fail_email.empty?
            flash[:success] = t('sendemail.created')
          else
            flash[:error] = t('sendemail.error.created')
          end
        end
        
        format.html { redirect_to request.referer }
      end
    end

  end

end
