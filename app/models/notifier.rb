#This class will compose all the mails that the application should send
class Notifier < ActionMailer::Base
  
  def invitation_email(invitation)
    setup_email(invitation.email)

    @subject += I18n.t("invitation.to_space",:space=>invitation.group.name,:username=>invitation.introducer.login)
    @body[:invitation] = invitation
    @body[:space] = invitation.group    
    @body[:user] = invitation.introducer
    if invitation.candidate
      @body[:name] = invitation.candidate.login
    else
      @body[:name] = invitation.email[0,invitation.email.index('@')]
    end
  end


  def event_invitation_email(invitation)
    setup_email(invitation.email)

    @subject += I18n.t("invitation.to_event",:space=>invitation.group.name,:username=>invitation.introducer.login)
    @body[:invitation] = invitation
    @body[:space] = invitation.group    
    @body[:event] = invitation.event
    @body[:user] = invitation.introducer
  end


  def processed_invitation_email(invitation, receiver)
    setup_email(receiver.email)
	
    action = invitation.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")
    @subject += I18n.t("e-mail.invitation_result.admin_side",:name=>invitation.candidate.name, :action => action, :spacename =>invitation.group.name)
    @body[:invitation] = invitation
    @body[:space] = invitation.group
    @body[:signature]  = Site.current.signature
    @body[:action] = action
  end

  def join_request_email(jr, receiver)
    setup_email(receiver.email)

    @subject += I18n.t("join_request.ask_subject", :candidate => jr.candidate.name, :space => jr.group.name)	
    @body[:candidate] = jr.candidate
    @body[:space] = jr.group
    @body ["contact_email"] = Site.current.email
    @body[:sender] = receiver
    @body[:signature]  = Site.current.signature	
  end

  def processed_join_request_email(jr)
    setup_email(jr.candidate.email)
	
    action = jr.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")
    @subject += I18n.t("e-mail.invitation_result.user_side", :action => action, :spacename =>jr.group.name)	
    @body[:jr] = jr
    @body[:space] = jr.group
    @body[:action] = action
  end

  #This is used when an user register in the application, in order to confirm his registration 
  def confirmation_email(user)
    setup_email(user.email)

    @subject += I18n.t("e-mail.welcome",:sitename=>Site.current.name)
    @body["name"] = user.login
    @body["hash"] = user.activation_code
    @body ["contact_email"] = Site.current.email
    @body[:signature]  = Site.current.signature		
  end

  def activation(user)
    setup_email(user.email)

    @subject += I18n.t("account_activated", :sitename=>Site.current.name)
    @body[:user] = user
    @body ["contact_email"] = Site.current.email
    @body[:url]  = "http://" + Site.current.domain + "/"
    @body[:sitename]  = Site.current.name
    @body[:signature]  = Site.current.signature	
  end
  
  #This is used when a user ask for his password.
  def lost_password(user)
    setup_email(user.email)

    @subject += I18n.t("password.request", :sitename=>Site.current.name)   
    @body ["name"] = user.login
    @body ["contact_email"] = Site.current.email
    @body["url"]  = "http://#{Site.current.domain}/reset_password/#{user.reset_password_code}" 
    @body[:signature]  = Site.current.signature		
  end

  #this methd is used when a user have asked for his old password, and then he reset it.
  def reset_password(user)
    setup_email(user.email)

    @subject += I18n.t("password.reset_email", :sitename=>Site.current.name)
    @body[:sitename]  = Site.current.name	
   	@body[:signature]  = Site.current.signature		
  end
  
  #this methd is used when a user have sent feedback to the admin.
  def feedback_email(email, subject, body)
    setup_email(Site.current.email)
    
    @from = email
    @subject += 'Feedback ' + subject
    @body ["text"] = body
    @body ["user"] = email
  end
  
  #this methd is used when a user have sent feedback to the admin.
  def spam_email(user,subject, body)
    setup_email(Site.current.email)
    
    @from = user.email
    @subject += subject
    @body ["text"] = body
    @body ["user"] = user.login
    @body[:sitename]  = Site.current.name
	@body[:signature]  = Site.current.signature		
  end
  
  private

  def setup_email(recipients)
    @recipients = recipients
    @from = "#{ Site.current.name } <#{ Site.current.email }>"
    @subject = "[VCC] "
    @sent_on = Time.now
    @content_type ="text/html"
  end

end
