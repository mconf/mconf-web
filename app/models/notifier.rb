# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

#This class will compose all the mails that the application should send
class Notifier < ActionMailer::Base
  
  def invitation_email(invitation)


    setup_email(invitation.email)


    @subject += I18n.t("invitation.to_space",:space=>invitation.group.name,:username=>invitation.introducer.full_name).html_safe.html_safe

    @invitation = invitation
    @space = invitation.group    
    @user = invitation.introducer

    if invitation.candidate
      @name = invitation.candidate.full_name
    else
      @name = invitation.email[0,invitation.email.index('@')]
    end
  #@headers.store("Reply-To",invitation.introducer.email)

  #@invitation = invitation
  upgmail(invitation.introducer.email)
  #mail(:to => @recipients, :subject => @subjecsalmonelat, :from => "eifion@asciicasts.com", :headers => @headers, "Reply-To" => invitation.introducer.email)
  end


  def event_invitation_email(invitation)
    setup_email(invitation.email)

    @subject += I18n.t("invitation.to_event",:eventname=>invitation.group.name,:space=>invitation.group.space.name,:username=>invitation.introducer.full_name).html_safe

    @invitation = invitation
    @space = invitation.group.space    
    @event = invitation.group
    @user = invitation.introducer
#    @headers.store("Reply-To",invitation.introducer.email)

  @invitation = invitation
  upgmail(invitation.introducer.email)
  end
  
  def event_notification_email(event,receiver)
    setup_email(receiver.email)

    user_sender = User.find(event.notif_sender_id)


    @subject += I18n.t("event.notification.subject",:eventname=>event.name,:space=>event.space.name,:username=>user_sender.full_name).html_safe

    @event = event
    @receiver = receiver
#    @headers.store("Reply-To",user_sender.email)

#    @invitation = receiver
    @event = event
    @receiver = receiver
    upgmail(user_sender.email)
  end
  
  
  def performance_update_notification_email(sender,receiver,stage,rol)
    setup_email(receiver.email)
    
    if stage.type.name == 'Space'
      @subject += I18n.t("performance.notification.subject.space", :username=>sender.full_name , :space=>stage.name).html_safe
      @text = I18n.t("performance.notification.space", :username=>sender.full_name , :space=>stage.name , :role => rol ).html_safe;
    elsif stage.type.name == 'Event'
      @subject += I18n.t("performance.notification.subject.event", :username=>sender.full_name , :event=>stage.name).html_safe
      @text = I18n.t("performance.notification.event", :username=>sender.full_name , :event=>stage.name , :role => rol ).html_safe;
    else
      @subject += I18n.t("performance.notification.subject.estandar", :username=>sender.full_name , :stage=>stage.name).html_safe
      @text = I18n.t("performance.notification.estandar").html_safe;
    end
 
    @sender = sender
    @receiver = receiver
#    @headers.store("Reply-To",sender.email)

    upgmail(sender.email)    
    
  end

  def space_group_invitation_email(space,mail)
    setup_email(mail)
    
    user_sender = User.find(space.group_inv_sender_id)
    @subject += I18n.t("space.group_invitation.subject",:space=>space.name,:username=>user_sender.full_name).html_safe.html_safe
    @space = space
    #@headers.store("Reply-To",user_sender.email)
    upgmail(user_sender.mail)
  end

  def event_group_invitation_email(event,mail)
    setup_email(mail)

    user_sender = User.find(event.group_inv_sender_id)
    @subject += I18n.t("event.group_invitation.subject",:eventname=>event.name,:space=>event.space.name,:username=>user_sender.full_name).html_safe
    @event = event
    #@headers.store("Reply-To",user_sender.email)
    upgmail(user_sender.email)
  end

  def processed_invitation_email(invitation, receiver)
    setup_email(receiver.email)
	
    action = invitation.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted").html_safe
    if invitation.candidate != nil
      @subject += I18n.t("e-mail.invitation_result.admin_side",:name=>invitation.candidate.name, :action => action, :spacename =>invitation.group.name).html_safe
    else
      @subject += I18n.t("e-mail.invitation_result.admin_side",:name=>invitation.email, :action => action, :spacename =>invitation.group.name).html_safe
    end
    @invitation = invitation
    @space = invitation.group
    @signature  = Site.current.signature_in_html
    @action = action
    #@headers.store("Reply-To",invitation.email)
    upgmail(invitation.email)  
  end

  def join_request_email(jr,receiver)
    setup_email(receiver.email)

    @subject += I18n.t("join_request.ask_subject", :candidate => jr.candidate.name, :space => jr.group.name).html_safe.html_safe	
    @join_request = jr
    @contact_email = Site.current.email
    @signature  = Site.current.signature_in_html
    #@headers.store("Reply-To",jr.candidate.email)
    upgmail(jr.candidate.email)
  end

  def processed_join_request_email(jr)
    setup_email(jr.candidate.email)
	
    action = jr.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted").html_safe
    @subject += I18n.t("e-mail.invitation_result.user_side", :action => action, :spacename =>jr.group.name).html_safe	
    @jr = jr
    @space = jr.group
    @action = action
   
  end

  #This is used when an user registers in the application, in order to confirm his registration 
  def confirmation_email(user)
    setup_email(user.email)

    @subject += I18n.t("e-mail.welcome",:sitename=>Site.current.name).html_safe
    @name = user.full_name
    @hash = user.activation_code
    @contact_email = Site.current.email
    @signature  = Site.current.signature_in_html	
  end

  def activation(user)
    setup_email(user.email)

    @subject += I18n.t("account_activated", :sitename=>Site.current.name).html_safe
    @user = user
    @contact_email = Site.current.email
    @url  = "http://" + Site.current.domain + "/"
    @sitename  = Site.current.name
    @signature  = Site.current.signature_in_html	
  end
  
  #This is used when a user asks for his password.
  def lost_password(user)
    setup_email(user.email)

    @subject += I18n.t("password.request", :sitename=>Site.current.name).html_safe   
    @name = user.full_name
    @contact_email = Site.current.email
    @url  = "http://#{Site.current.domain}/reset_password/#{user.reset_password_code}" 
    @signature  = Site.current.signature_in_html		
  end

  #this method is used when a user has asked for his old password, and then he resets it.
  def reset_password(user)
    setup_email(user.email)

    @subject += I18n.t("password.reset_email", :sitename=>Site.current.name).html_safe
    @sitename  = Site.current.name	
   	@signature = Site.current.signature_in_html
   		
  end
  
  #this method is used when a user has sent feedback to the admin.
  def feedback_email(email, subject, body)
    setup_email(Site.current.email)
    
    @from = email
    @subject += I18n.t("feedback.one").html_safe + " " + subject
    @text = body
    @user = email
  end
  
  #this method is used when a user has sent feedback to the admin.
  def spam_email(user,subject, body, url)
    setup_email(Site.current.email)
    
    @from = user.email
    @subject += subject
    @text = I18n.t("spam.item").html_safe + ": " + url + "<br/>"
    @text += body
    @user = user.full_name
    @sitename  = Site.current.name
    @signature  = Site.current.signature_in_html		
  end
  
  def webconference_invite_email(inv_email)
    setup_email(inv_email[:email_receiver])
    @from = inv_email[:email_sender]
    
    @user_name = inv_email[:user_name]
    @room_name = inv_email[:room_name]
    @room_url = inv_email[:room_url]
    
    @subject = inv_email[:title]
    @text = inv_email[:body]
    
  end
  
  private

  def setup_email(recipients)
    @recipients = recipients
    @from = "#{ Site.current.name } <#{ Site.current.email }>"
    @subject = I18n.t("vcc_mail_label").html_safe + " "
    @sent_on = Time.now
    @content_type ="text/html"
    
    
  end
#Tuesday, March 01 2011, intended to eliminate warnings and allow rails3 upgrade
#=begin
  def upgmail (repto)
    mail(:to => @recipients, :subject => @subject, :from => @from, :headers => @headers, "Reply-To" => repto)
  end
#=end
end
