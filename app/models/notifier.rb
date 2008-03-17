#This class will compose all the mails that the application should send
class Notifier < ActionMailer::Base
  
  #this method is used to compose the mail sended when a user request more machines in the application
  def contact_mail (mail_info)
    @from = mail_info["from_email"]
     @recipients = "alfredo@lowcostronica.es"
     @subject = "SIR Information"
     @mail_info = mail_info
     @body["mail_info"] = mail_info
     @sent_on = Time.now
  
 part :content_type => "text/plain",
 :body => render_message("contact_mail_plain", "mail_info" => mail_info)
  
 part :content_type => "text/html",
 :body => render_message("contact_mail_html", "mail_info" => mail_info) 
  
    
  end
  
  #This is used when an user register in the application, in order to confirm his registration 
  def confirmation_email(user)
    # email header info MUST be added here
    @recipients = user.email
    @from = "Isabel Development Team"
    @subject = "SIR Information:: Welcome to SIR"

    # email body substitutions go here
    @body["name"] = user.login
    @body["hash"] = user.activation_code
  end
  #This method compose the email used when a user is deleted from the system
  def byebye (user, sent_at = Time.now)
    @subject = "SIR Information::User Deleted"
    @from = "alsolano@dit.upm.es"
    @recipients = user.email
     @sent_on = sent_at
    @body = "Your user in SIR has been deleted. Please contact the administrator for more information"
  end
  #This is used when a user ask for his password.
  def forgot_password(user)
    @recipients = user.email
    @from = "alsolano@dit.upm.es"
    @subject    = 'Request to change your password'
    @body ["name"] = user.login
    @body["url"]  = "http://macarra.dit.upm.es:3000/reset_password/#{user.reset_password_code}" 
  end
#this methd is used when a user have asked for his old password, and then he reset it.
  def reset_password(user)
    @recipients = user.email
    @from = "alsolano@dit.upm.es"
    @body ["name"] = user.login
    @subject    = 'Your password has been reset'
  end
  
end
