# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe FeedbackController do
  render_views

  describe "#webconf" do
    before do
      Site.current.update_attributes :feedback_url => url
      get :webconf
    end

    context 'with feedback url' do
      let(:url) { '/any' }
      it { should redirect_to url }
    end

    context 'without feedback url' do
      let(:url) { nil }
      it { should render_with_layout 'no_sidebar' }
      it { should render_template 'webconf'}
    end
  end

  describe "#new" do
    context "with user logged in" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in(user) }
      context 'get' do
        before { get :new }
        it { should render_template 'new' }
        it { should render_with_layout 'application' }
      end

      context 'xhr' do
        before { xhr :get, :new }
        it { should render_template 'new' }
        it { should_not render_with_layout }
      end
    end

    context "as anonymous user" do
      context 'get' do
        before { get :new }
        it { should redirect_to '/users/login' }
      end

      context 'xhr' do
        before { xhr :get, :new }
        it { response.status.should eql 401 }
      end
    end
  end

  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:email) { user.email }
    let!(:message) { 'The gods of the city have called my name' }
    let!(:subj) { 'Anne' } # can't call it 'subject' because it's reserved by rspec
    let(:attrs) { { :from => email, :message => message, :subject => subj } }

    context "with user logged in" do
      let!(:url) { '/any' }
      before {
        sign_in(user)
        request.env['HTTP_REFERER'] = url
        post :create, :feedback => attrs
      }

      context 'with valid data' do
        it { should redirect_to url }
        it { should set_the_flash.to(I18n.t('feedback.create.success')) }
        it { ApplicationMailer.should have_queue_size_of(1) }
        it { ApplicationMailer.should have_queued(:feedback_email, email, subj, message) }
      end

      shared_examples 'the email is not sent' do
        it { ApplicationMailer.should have_queue_size_of(0) }
        it { ApplicationMailer.should_not have_queued(:feedback_email, email, subj, message) }
      end

      context 'email' do
        context 'is missing' do
          let(:email) { '' }

          it { should redirect_to url }
          it { should set_the_flash.to(I18n.t('feedback.create.check_mail')) }
          it_behaves_like 'the email is not sent'
        end

        context 'is not a valid email' do
          let(:email) { 'john[at]fruscian.te' }

          it { should redirect_to url }
          it { should set_the_flash.to(I18n.t('feedback.create.check_mail')) }
          it_behaves_like 'the email is not sent'
        end
      end

      context 'subject is missing' do
        let(:subj) { '' }

        it { should redirect_to url }
        it { should set_the_flash.to(I18n.t('feedback.create.fill_fields')) }
        it_behaves_like 'the email is not sent'
      end

      context 'message is missing' do
        let(:message) { '' }

        it { should redirect_to url }
        it { should set_the_flash.to(I18n.t('feedback.create.fill_fields')) }
        it_behaves_like 'the email is not sent'
      end
    end

    context "as anonymous user" do
      before {
        post :create, feedback: attrs
      }
      it { should redirect_to '/users/login' }
    end
  end

end
