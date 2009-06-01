#This class will compose all the mails that the application should send
class Notifier < ActionMailer::Base
  
  def invitation_email(invitation)
    setup_email(invitation.email)

    @subject += "Invitation"
    @body[:invitation] = invitation
    @body[:space] = invitation.group
  end

  def processed_invitation_email(invitation)
    setup_email(invitation.group.users(:role => 'Admin').map(&:email))

    @subject += "Invitation #{ invitation.accepted? ? 'accepted' : 'discarded' }"
    @body[:invitation] = invitation
    @body[:space] = invitation.group
  end

  def join_request_email(jr)
    setup_email(jr.group.users(:role => 'Admin').map(&:email))

    @subject += "Join Request"
    @body[:candidate] = jr.candidate
    @body[:space] = jr.group
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
  end

  def activation(user)
    setup_email(user.email)

    @subject     += I18n.t(:account_activated)
    @body[:user] = user
    @body[:url]  = "http://#{ Site.current.domain }/"
  end
  
  #This is used when a user ask for his password.
  def lost_password(user)
    setup_email(user.email)

    @subject += 'Request to change your password'
    @body ["name"] = user.login
    @body["url"]  = "http://#{Site.current.domain}/reset_password/#{user.reset_password_code}" 
  end

  #this methd is used when a user have asked for his old password, and then he reset it.
  def reset_password(user)
    setup_email(user.email)

    @body ["name"] = user.login
    @subject += 'Your password has been reset'
  end

  private

  def setup_email(recipients)
    @recipients = recipients
    @from       = "#{ Site.current.name } <#{ Site.current.email }>"
    @subject    = "[VCC] "
    @sent_on    = Time.now
  end

end
