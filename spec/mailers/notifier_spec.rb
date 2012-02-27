require "spec_helper"

describe Notifier do

  before(:each) do
    @space = Factory(:space)
    @event = Factory(:event)
    @admin = Factory(:admin_performance, :stage => @space).agent
    @registered_user = Factory(:user_performance).agent
    @unregistered_user_email = "unregistered@example.com"

    @admin.profile.update_attributes FactoryGirl.attributes_for(:profile)
    @admin.update_attribute(:notification,User::NOTIFICATION_VIA_EMAIL)
    @registered_user.profile.update_attributes FactoryGirl.attributes_for(:profile)
    @registered_user.update_attribute(:notification,User::NOTIFICATION_VIA_EMAIL)
    @event.update_attribute(:space, @space)
    @event.update_attribute(:author, @admin)
  end

  describe "in the space invitation email, when the receiver is" do
    it "an unregistered user it should include the receiver's email, the introducer's name, email and organization, the name and URL of the space and the URL of the invitation" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("User").id.to_s, :email => @unregistered_user_email}
      invitation = @space.invitations.build params
      invitation_comment = "Join this space."
      invitation.update_attributes(:comment => invitation_comment, :introducer => @admin)

      # Check the subject content
      ActionMailer::Base.deliveries.first.subject.should include(@space.name)
      ActionMailer::Base.deliveries.first.subject.should include(@admin.name)

      # Check the body content
      ActionMailer::Base.deliveries.first.body.should include(@unregistered_user_email[0,@unregistered_user_email.index('@')])

      email_body = I18n.t('invitation.full_message',
        :username => @admin.full_name,
        :space => @space.name,
        :comment => invitation_comment,
        :url => invitation_url(invitation),
        :space_url => space_url(@space),
        :user_name => @admin.full_name,
        :user_email => @admin.email,
        :user_organization => @admin.organization,
        :contact => Site.current.email,
        :feedback => new_feedback_url()
      ).html_safe

      # Check the content of the body
      ActionMailer::Base.deliveries.first.body.should match(email_body)
    end

    it "a registered user it should include the receiver's name, the introducer's name, email and organization, the name and URL of the space and the URL of the invitation" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("User").id.to_s, :email => @registered_user.email}
      invitation = @space.invitations.build params
      invitation_comment = "Join this space."
      invitation.update_attributes(:comment => invitation_comment, :introducer => @admin)

      # Check the subject content
      ActionMailer::Base.deliveries.first.subject.should include(@space.name)
      ActionMailer::Base.deliveries.first.subject.should include(@admin.name)

      # Check the body content
      ActionMailer::Base.deliveries.first.body.should include(@registered_user.full_name)

      email_body = I18n.t('invitation.full_message',
        :username => @admin.full_name,
        :space => @space.name,
        :comment => invitation_comment,
        :url => invitation_url(invitation),
        :space_url => space_url(@space),
        :user_name => @admin.full_name,
        :user_email => @admin.email,
        :user_organization => @admin.organization,
        :contact => Site.current.email,
        :feedback => new_feedback_url()
      ).html_safe

      # Check the content of the body
      ActionMailer::Base.deliveries.first.body.should match(email_body)
    end

  end

  #describe para event invitation
  #describe "in the event invitation email" do
  #  it "shoul include the sender's name, email, the name of the space and the name and url of the event" do
  #
  #    msg = I18n.t('event.invite_message',
  #      :event_name => @event.name,
  #      :space => @space.name,
  #      :event_date => @event.start_date.strftime("%A %B %d at %H:%M:%S"),
  #      :event_url => space_event_url(@space,@event),
  #      :username => @admin.full_name,
  #      :useremail => @admin.email,
  #      :userorg => @admin.organization
  #    ).html_safe
  #
  #
  #  end
  #end

  #describe "in the event notification email" do
  #  it "should include the receiver's name, the sender's name, email and organization, the name of the space and the name and URL of the event" do

      # Build the notification
#      msg = I18n.t('event.notification.message_beginning_with_start_date', :space => @space.name).
#        gsub('\'event_name\'', @event.name).gsub('\'event_date\'', @event.start_date.strftime("%A %B %d at %H:%M:%S"))
#      msg += I18n.t('event.notification.message_ending', :username => @admin.full_name, :useremail => @admin.email, :userorg => @admin.organization).
#        gsub('event_url',"http://" + Site.current.domain + "/spaces/" + @space.permalink + "/events/" + @event.permalink)
#      @event.update_attributes(:notify_msg => msg, :notif_sender_id => @admin.id)
#      Informer.deliver_event_notification(@event, @registered_user)

      # Check the subject content
#      ActionMailer::Base.deliveries.first.subject.should include(@event.name)
#      ActionMailer::Base.deliveries.first.subject.should include(@space.name)
#      ActionMailer::Base.deliveries.first.subject.should include(@admin.name)

      # Check the body content
#      ActionMailer::Base.deliveries.first.body.should include(@registered_user.full_name)
#      ActionMailer::Base.deliveries.first.body.should include(@admin.name)
#      ActionMailer::Base.deliveries.first.body.should include(@admin.email)
#      ActionMailer::Base.deliveries.first.body.should include(@admin.organization)
#      ActionMailer::Base.deliveries.first.body.should include(@space.name)
#      ActionMailer::Base.deliveries.first.body.should include(@event.name)
#      ActionMailer::Base.deliveries.first.body.should include("http://" + Site.current.domain + "/spaces/" + @space.permalink + "/events/" + @event.permalink)

#    end
#  end

  describe "in the processed invitation email, when the invited user is" do
    it "unregistered it should include the receiver's name, the invited user's email and response, the name of the space, the URL of the space users and the signature of the site" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("User").id.to_s, :email => @unregistered_user_email}
      invitation = @space.invitations.build params
      invitation_comment = "<p>\'" + I18n.t('name.one') + "\',</p>" + "<b>" + I18n.t('invitation.to_space', :username => @admin.full_name, :space => @space.name) + ".</b><br/><br/>" +
        I18n.t('invitation.to_accept_space', :url=>'\'' + I18n.t('url_plain') + '\'') + "<br/>" +
        I18n.t('invitation.info_space', :space_url => ("http://" + Site.current.domain + "/spaces/" + @space.permalink)) + "<br/><br/>" +
        I18n.t('email.kind_regards') + "<br/><br/>" +
        @admin.full_name + "<br/>" + @admin.email + "<br/>" + @admin.organization + "<br/>"
      invitation.update_attributes(:comment => invitation_comment, :introducer => @admin)
      invitation.update_attributes(:processed => true, :accepted => true)
      action = invitation.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")

      # Check the subject content
      ActionMailer::Base.deliveries[1].subject.should include(@unregistered_user_email)
      ActionMailer::Base.deliveries[1].subject.should include(action)
      ActionMailer::Base.deliveries[1].subject.should include(@space.name)

      # Check the body content
      ActionMailer::Base.deliveries[1].body.should include(@admin.name)
      ActionMailer::Base.deliveries[1].body.should include(@unregistered_user_email[0,@unregistered_user_email.index('@')])
      ActionMailer::Base.deliveries[1].body.should include(action)
      ActionMailer::Base.deliveries[1].body.should include(@space.name)
      ActionMailer::Base.deliveries[1].body.should include("http://" + Site.current.domain + "/spaces/" + @space.permalink + "/users")
      ActionMailer::Base.deliveries[1].body.should include(Site.current.signature_in_html)

    end

    it "registered it should include the receiver's name, the invited user's name and response, the name of the space, the URL of the space users and the signature of the site" do

      # Build the invitation
      params = {:role_id => Role.find_by_name("User").id.to_s, :email => @registered_user.email}
      invitation = @space.invitations.build params
      invitation_comment = "<p>\'" + I18n.t('name.one') + "\',</p>" + "<b>" + I18n.t('invitation.to_space', :username => @admin.full_name, :space => @space.name) + ".</b><br/><br/>" +
        I18n.t('invitation.to_accept_space', :url=>'\'' + I18n.t('url_plain') + '\'') + "<br/>" +
        I18n.t('invitation.info_space', :space_url => ("http://" + Site.current.domain + "/spaces/" + @space.permalink)) + "<br/><br/>" +
        I18n.t('email.kind_regards') + "<br/><br/>" +
        @admin.full_name + "<br/>" + @admin.email + "<br/>" + @admin.organization + "<br/>"
      invitation.update_attributes(:comment => invitation_comment, :introducer => @admin)
      invitation.update_attributes(:processed => true, :accepted => true)
      action = invitation.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")

      # Check the subject content
      ActionMailer::Base.deliveries[1].subject.should include(@registered_user.full_name)
      ActionMailer::Base.deliveries[1].subject.should include(action)
      ActionMailer::Base.deliveries[1].subject.should include(@space.name)

      # Check the body content
      ActionMailer::Base.deliveries[1].body.should include(@admin.name)
      ActionMailer::Base.deliveries[1].body.should include(@registered_user.full_name)
      ActionMailer::Base.deliveries[1].body.should include(action)
      ActionMailer::Base.deliveries[1].body.should include(@space.name)
      ActionMailer::Base.deliveries[1].body.should include("http://" + Site.current.domain + "/spaces/" + @space.permalink + "/users")
      ActionMailer::Base.deliveries[1].body.should include(Site.current.signature_in_html)

    end

  end

  describe "in the space join request email" do

    it "should include the candidate's name, the name of the space, the URL of the admissions of the space and the signature of the site" do

      # Build the join request
      jr_comment = "Accept my solicitation"
      params = {:candidate => @registered_user, :email => @registered_user.email, :group => @space, :comment => jr_comment}
      jr = @space.join_requests.build params
      jr.save!

      # Check the content of the subject
      ActionMailer::Base.deliveries.first.subject.should include(@registered_user.full_name)
      ActionMailer::Base.deliveries.first.subject.should include(@space.name)

      # Check the content of the body
      email_body = I18n.t('join_request.asked_full',
        :candidate => @registered_user.full_name,
        :space => @space.name,
        :comment => "Accept my solicitation",
        :url =>  space_admissions_url(@space),
        :contact => Site.current.email,
        :feedback => new_feedback_url(),
        :signature => Site.current.signature_in_html
        ).html_safe

      # Check the content of the body
      ActionMailer::Base.deliveries.first.body.should match(email_body)

    end

  end

  describe "in the processed join request email" do

    it "should include whether the request has been accepted or not and the name and URL of the space" do

      # Build the join request
      jr_comment = "<p>" + I18n.t('join_request.asked', :candidate => @registered_user.full_name, :space => @space.name) + "</p>" +
        "<p>" + I18n.t('join_request.to_accept_space', :url => ("http://" + Site.current.domain + "/spaces/" + @space.permalink + "admissions")) + "</p>" +
        "<p>" + Site.current.signature_in_html + "</p>"
      params = {:candidate => @registered_user, :email => @registered_user.email, :group => @space, :comment => jr_comment}
      jr = @space.join_requests.build params
      jr.save!
      jr.update_attributes(:processed => true, :accepted => true, :role_id => Role.find_by_name("User").id.to_s, :introducer => @admin)
      action = jr.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")

      # Check the content of the subject
      ActionMailer::Base.deliveries[1].subject.should include(action)
      ActionMailer::Base.deliveries[1].subject.should include(@space.name)

      # Check the content of the body
      ActionMailer::Base.deliveries[1].body.should include(action)
      ActionMailer::Base.deliveries[1].body.should include(@space.name)
      ActionMailer::Base.deliveries[1].body.should include("http://" + Site.current.domain + "/spaces/" + @space.permalink)

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
