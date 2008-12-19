#This class will compose all the mails that the application should send
class Notifier < ActionMailer::Base
  
  #this method is used to compose the mail sended when a user request more machines in the application
  def contact_mail (mail_info)
    @from = mail_info["from_email"]
     @recipients = "#{Site.current.email}"
     @subject = "SIR Information"
     @mail_info = mail_info
     @body["mail_info"] = mail_info
     @sent_on = Time.now
  
 part :content_type => "text/plain",
 :body => render_message("contact_mail_plain", "mail_info" => mail_info)
  
 part :content_type => "text/html",
 :body => render_message("contact_mail_html", "mail_info" => mail_info) 
  end
  
  def invitation_email(invitation)
    @profile = Profile.find_by_user_id(invitation.user_id)
    @user = User.find(invitation.user_id)
    @space = Space.find(invitation.space_id)
    @from = @user.email
     @recipients = invitation.email
     @subject = "Sir Invitation"
     @sent_on = Time.now
     @body["space_id"] = invitation.space_id
     @body["name"] = @profile.name if @profile
       @body["lastname"] = @profile.lastname if @profile
     @body["space"] = @space.name
  end
  
  #This is used when an user register in the application, in order to confirm his registration 
  def confirmation_email(user)
    # email header info MUST be added here
    @recipients = user.email
    @from = "#{Site.current.email}"
    @subject = "SIR Information:: Welcome to SIR"

    # email body substitutions go here
    @body["name"] = user.login
    @body["hash"] = user.activation_code
  end
  
  #This method compose the email used when a user is deleted from the system
  def byebye (user, sent_at = Time.now)
    @subject = "SIR Information::User Deleted"
    @from = "#{Site.current.email}"
    @recipients = user.email
     @sent_on = sent_at
    @body = "Your user in SIR has been deleted. Please contact the administrator for more information"
  end
  #This is used when a user ask for his password.
  def forgot_password(user)
    @recipients = user.email
    @from = "#{Site.current.email}"
    @subject    = 'Request to change your password'
    @body ["name"] = user.login
    @body["url"]  = "http://#{Site.current.domain}/reset_password/#{user.reset_password_code}" 
  end
#this methd is used when a user have asked for his old password, and then he reset it.
  def reset_password(user)
    @recipients = user.email
    @from = "#{Site.current.email}"
    @body ["name"] = user.login
    @subject    = 'Your password has been reset'
  end
  
end
