#This class will compose all the mails that the application should send
class Notifier < ActionMailer::Base
  
  def invitation_email(invitation)
    setup_email(invitation.email)

    @subject += "Invitation"
    @body[:invitation] = invitation
    @body[:space] = invitation.group    
    @body[:user] = invitation.introducer
  end


  def event_invitation_email(invitation)
    setup_email(invitation.email)

    @subject += I18n.t("invitation.subject",:space=>invitation.group,:username=>invitation.introducer)
    @body[:invitation] = invitation
    @body[:space] = invitation.group    
    @body[:event] = invitation.event
    @body[:user] = invitation.introducer
  end


  def processed_invitation_email(invitation, receiver)
    setup_email(receiver.email)

    @subject += "Invitation #{ invitation.accepted? ? 'accepted' : 'discarded' }"
    @body[:invitation] = invitation
    @body[:space] = invitation.group
  end

  def join_request_email(jr, receiver)
    setup_email(receiver.email)

    @subject += "Join Request"
    @body[:candidate] = jr.candidate
    @body[:space] = jr.group
    @body ["contact_email"] = Site.current.email
    @body[:sender] = jr.introducer
  end

  def processed_join_request_email(jr)
    setup_email(jr.candidate.email)

    @subject += "Join Request #{ jr.accepted? ? 'accepted' : 'discarded' }"
    @body[:jr] = jr
    @body[:space] = jr.group
  end

  #This is used when an user register in the application, in order to confirm his registration 
  def confirmation_email(user)
    setup_email(user.email)

    @subject += "Welcome to VCC"
    @body["name"] = user.login
    @body["hash"] = user.activation_code
    @body ["contact_email"] = Site.current.email
  end

  def activation(user)
    setup_email(user.email)

    @subject     += I18n.t(:account_activated)
    @body[:user] = user
    @body ["contact_email"] = Site.current.email
    @body[:url]  = "http://#{ Site.current.domain }/"
  end
  
  #This is used when a user ask for his password.
  def lost_password(user)
    setup_email(user.email)

    @subject += 'Request to change your password'
    @body ["name"] = user.login
    @body ["contact_email"] = Site.current.email
    @body["url"]  = "http://#{Site.current.domain}/reset_password/#{user.reset_password_code}" 
  end

  #this methd is used when a user have asked for his old password, and then he reset it.
  def reset_password(user)
    setup_email(user.email)

    @body ["name"] = user.login
    @body ["contact_email"] = Site.current.email
    @subject += 'Your password has been reset'
  end
  
  #this methd is used when a user have sent feedback to the admin.
  def feedback_email(email, subject, body)
    setup_email(Site.current.email)
    
    @from = email
    @subject += ' Feedback  ' + subject
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
  end
  
  private

  def setup_email(recipients)
    @recipients = recipients
    @from       = "#{ Site.current.name } <#{ Site.current.email }>"
    @subject    = "[VCC] "
    @sent_on    = Time.now
  end

end
