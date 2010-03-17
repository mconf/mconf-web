require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Notifier do

  before(:each) do

    @space = Factory(:space)
    @event = Factory(:event)
    @admin = Factory(:admin_performance, :stage => @space).agent
    @registered_user = Factory(:user_performance).agent
    @unregistered_user_email = "unregistered@example.com"
    
    @admin.profile.update_attributes Factory.attributes_for(:profile)
    @registered_user.profile.update_attributes Factory.attributes_for(:profile)
    @event.update_attribute(:space, @space)
    @event.update_attribute(:author, @admin)

    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  
  describe "in the space invitation email, when the receiver is" do
    it "an unregistered user it should include the receiver's email, the introducer's name, email and organization, the name and URL of the space and the URL of the invitation" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("User").id.to_s, :email => @unregistered_user_email}
      invitation = @space.invitations.build params
      invitation_comment = "<p>\'" + I18n.t('name.one') + "\',</p>" + "<b>" + I18n.t('invitation.to_space', :username => @admin.full_name, :space => @space.name) + ".</b><br/><br/>" +
        I18n.t('invitation.to_accept_space', :url=>'\'' + I18n.t('url_plain') + '\'') + "<br/>" +
        I18n.t('invitation.info_space', :space_url => ("http://" + Site.current.domain + "/spaces/" + @space.permalink)) + "<br/><br/>" +
        I18n.t('e-mail.kind_regards') + "<br/><br/>" +
        @admin.full_name + "<br/>" + @admin.email + "<br/>" + @admin.organization + "<br/>"
      invitation.update_attributes(:comment => invitation_comment, :introducer => @admin)
      
      # Check the subject content
      ActionMailer::Base.deliveries.first.subject.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.subject.should include_text(@admin.name)
      
      # Check the body content
      ActionMailer::Base.deliveries.first.body.should include_text(@unregistered_user_email[0,@unregistered_user_email.index('@')])
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.name)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.email)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.organization)
      ActionMailer::Base.deliveries.first.body.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/spaces/" + @space.permalink)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/invitations/" + invitation.code)
      
    end

    it "a registered user it should include the receiver's name, the introducer's name, email and organization, the name and URL of the space and the URL of the invitation" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("User").id.to_s, :email => @registered_user.email}
      invitation = @space.invitations.build params
      invitation_comment = "<p>\'" + I18n.t('name.one') + "\',</p>" + "<b>" + I18n.t('invitation.to_space', :username => @admin.full_name, :space => @space.name) + ".</b><br/><br/>" +
        I18n.t('invitation.to_accept_space', :url=>'\'' + I18n.t('url_plain') + '\'') + "<br/>" +
        I18n.t('invitation.info_space', :space_url => ("http://" + Site.current.domain + "/spaces/" + @space.permalink)) + "<br/><br/>" +
        I18n.t('e-mail.kind_regards') + "<br/><br/>" +
        @admin.full_name + "<br/>" + @admin.email + "<br/>" + @admin.organization + "<br/>"
      invitation.update_attributes(:comment => invitation_comment, :introducer => @admin)
      
      # Check the subject content
      ActionMailer::Base.deliveries.first.subject.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.subject.should include_text(@admin.name)
      
      # Check the body content
      ActionMailer::Base.deliveries.first.body.should include_text(@registered_user.full_name)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.name)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.email)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.organization)
      ActionMailer::Base.deliveries.first.body.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/spaces/" + @space.permalink)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/invitations/" + invitation.code)

    end

  end
    
  describe "in the event invitation email, when the receiver is" do
    it "an unregistered user it should include the receiver's email, the introducer's name, email and organization, the name of the space, the name and URL of the event and the URL of the invitation" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("Invited").id.to_s, :email => @unregistered_user_email}
      invitation = @event.invitations.build params
      invitation_comment = "<p>\'" + I18n.t('name.one') + "\',</p>" +
        I18n.t('invitation.message.' + (Event::VC_MODE[@event.vc_mode]).to_s ,:space=>@space.name,:url=>'\'' + I18n.t('url_plain') + '\'',:contact => Site.current.email, :feedback => "http://" + Site.current.domain.to_s + "feedback/new",:username=>@admin.full_name,:useremail=>@admin.email,:userorg=>@admin.organization).gsub('\'event_name\'',@event.name).gsub('\'event_date\'', @event.start_date.strftime("%A %B %d at %H:%M:%S")).gsub('event_url', "http://" + Site.current.domain + "/spaces/" + @space.permalink + "/events/" + @event.permalink)
      invitation.update_attributes(:comment => invitation_comment, :introducer => @event.author)
      
      # Check the subject content
      ActionMailer::Base.deliveries.first.subject.should include_text(@event.name)
      ActionMailer::Base.deliveries.first.subject.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.subject.should include_text(@admin.name)
      
      # Check the body content
      ActionMailer::Base.deliveries.first.body.should include_text(@unregistered_user_email[0,@unregistered_user_email.index('@')])
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.name)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.email)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.organization)
      ActionMailer::Base.deliveries.first.body.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.body.should include_text(@event.name)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/spaces/" + @space.permalink + "/events/" + @event.permalink)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/invitations/" + invitation.code)

    end

    it "a registered user it should include the receiver's name, the introducer's name, email and organization, the name of the space, the name and URL of the event and the URL of the invitation" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("Invited").id.to_s, :email => @registered_user.email}
      invitation = @event.invitations.build params
      invitation_comment = "<p>\'" + I18n.t('name.one') + "\',</p>" +
        I18n.t('invitation.message.' + (Event::VC_MODE[@event.vc_mode]).to_s ,:space=>@space.name,:url=>'\'' + I18n.t('url_plain') + '\'',:contact => Site.current.email, :feedback => "http://" + Site.current.domain.to_s + "feedback/new",:username=>@admin.full_name,:useremail=>@admin.email,:userorg=>@admin.organization).gsub('\'event_name\'',@event.name).gsub('\'event_date\'', @event.start_date.strftime("%A %B %d at %H:%M:%S")).gsub('event_url', "http://" + Site.current.domain + "/spaces/" + @space.permalink + "/events/" + @event.permalink)
      invitation.update_attributes(:comment => invitation_comment, :introducer => @event.author)
      
      # Check the subject content
      ActionMailer::Base.deliveries.first.subject.should include_text(@event.name)
      ActionMailer::Base.deliveries.first.subject.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.subject.should include_text(@admin.name)
      
      # Check the body content
      ActionMailer::Base.deliveries.first.body.should include_text(@registered_user.full_name)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.name)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.email)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.organization)
      ActionMailer::Base.deliveries.first.body.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.body.should include_text(@event.name)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/spaces/" + @space.permalink + "/events/" + @event.permalink)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/invitations/" + invitation.code)

    end

  end
  
  describe "in the event notification email" do
    it "should include the receiver's name, the sender's name, email and organization, the name of the space and the name and URL of the event" do

      # Build the notification
      msg = I18n.t('event.notification.message_beginning' ,:space=>@space.name).gsub('\'event_name\'',@event.name).gsub('\'event_date\'', @event.start_date.strftime("%A %B %d at %H:%M:%S")) +
        I18n.t('event.notification.message_ending' ,:username=>@admin.full_name,:useremail=>@admin.email,:userorg=>@admin.organization).gsub('event_url',"http://" + Site.current.domain + "/spaces/" + @space.permalink + "/events/" + @event.permalink)
      @event.update_attribute(:notify_msg, msg)
      Informer.deliver_event_notification(@event,@registered_user)
      
      # Check the subject content
      ActionMailer::Base.deliveries.first.subject.should include_text(@event.name)
      ActionMailer::Base.deliveries.first.subject.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.subject.should include_text(@admin.name)
      
      # Check the body content
      ActionMailer::Base.deliveries.first.body.should include_text(@registered_user.full_name)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.name)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.email)
      ActionMailer::Base.deliveries.first.body.should include_text(@admin.organization)
      ActionMailer::Base.deliveries.first.body.should include_text(@space.name)
      ActionMailer::Base.deliveries.first.body.should include_text(@event.name)
      ActionMailer::Base.deliveries.first.body.should include_text("http://" + Site.current.domain + "/spaces/" + @space.permalink + "/events/" + @event.permalink)

    end
  end
  
  describe "in the processed invitation email, when the invited user is" do
    it "unregistered it should include the receiver's name, the invited user's email and response, the name of the space, the URL of the space users and the signature of the site" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("User").id.to_s, :email => @unregistered_user_email}
      invitation = @space.invitations.build params
      invitation_comment = "<p>\'" + I18n.t('name.one') + "\',</p>" + "<b>" + I18n.t('invitation.to_space', :username => @admin.full_name, :space => @space.name) + ".</b><br/><br/>" +
        I18n.t('invitation.to_accept_space', :url=>'\'' + I18n.t('url_plain') + '\'') + "<br/>" +
        I18n.t('invitation.info_space', :space_url => ("http://" + Site.current.domain + "/spaces/" + @space.permalink)) + "<br/><br/>" +
        I18n.t('e-mail.kind_regards') + "<br/><br/>" +
        @admin.full_name + "<br/>" + @admin.email + "<br/>" + @admin.organization + "<br/>"
      invitation.update_attributes(:comment => invitation_comment, :introducer => @admin)
      invitation.update_attribute(:accepted, true)
      action = invitation.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")

      # Check the subject content
      ActionMailer::Base.deliveries[1].subject.should include_text(@unregistered_user_email)
      ActionMailer::Base.deliveries[1].subject.should include_text(action)
      ActionMailer::Base.deliveries[1].subject.should include_text(@space.name)
      
      # Check the body content
      ActionMailer::Base.deliveries[1].body.should include_text(@admin.name)
      ActionMailer::Base.deliveries[1].body.should include_text(@unregistered_user_email[0,@unregistered_user_email.index('@')])
      ActionMailer::Base.deliveries[1].subject.should include_text(action)
      ActionMailer::Base.deliveries[1].body.should include_text(@space.name)
      ActionMailer::Base.deliveries[1].body.should include_text("http://" + Site.current.domain + "/spaces/" + @space.permalink + "/users")
      ActionMailer::Base.deliveries[1].body.should include_text(Site.current.signature_in_html)
      
    end
    
    it "registered it should include the receiver's name, the invited user's name and response, the name of the space, the URL of the space users and the signature of the site" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("User").id.to_s, :email => @registered_user.email}
      invitation = @space.invitations.build params
      invitation_comment = "<p>\'" + I18n.t('name.one') + "\',</p>" + "<b>" + I18n.t('invitation.to_space', :username => @admin.full_name, :space => @space.name) + ".</b><br/><br/>" +
        I18n.t('invitation.to_accept_space', :url=>'\'' + I18n.t('url_plain') + '\'') + "<br/>" +
        I18n.t('invitation.info_space', :space_url => ("http://" + Site.current.domain + "/spaces/" + @space.permalink)) + "<br/><br/>" +
        I18n.t('e-mail.kind_regards') + "<br/><br/>" +
        @admin.full_name + "<br/>" + @admin.email + "<br/>" + @admin.organization + "<br/>"
      invitation.update_attributes(:comment => invitation_comment, :introducer => @admin)
      invitation.update_attribute(:accepted, true)
      action = invitation.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")

      # Check the subject content
      ActionMailer::Base.deliveries[1].subject.should include_text(@registered_user.full_name)
      ActionMailer::Base.deliveries[1].subject.should include_text(action)
      ActionMailer::Base.deliveries[1].subject.should include_text(@space.name)
      
      # Check the body content
      ActionMailer::Base.deliveries[1].body.should include_text(@admin.name)
      ActionMailer::Base.deliveries[1].body.should include_text(@registered_user.full_name)
      ActionMailer::Base.deliveries[1].subject.should include_text(action)
      ActionMailer::Base.deliveries[1].body.should include_text(@space.name)
      ActionMailer::Base.deliveries[1].body.should include_text("http://" + Site.current.domain + "/spaces/" + @space.permalink + "/users")
      ActionMailer::Base.deliveries[1].body.should include_text(Site.current.signature_in_html)

    end

  end
  
  after(:each) do 
    #remove all the stuff created
    @space.destroy
    @event.destroy
    @admin.destroy
    @registered_user.destroy
  end

end
