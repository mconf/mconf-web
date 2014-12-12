require 'spec_helper'

def send_feedback subj, message, email=nil
  fill_in 'feedback[from]', :with => email if email.present?
  fill_in 'feedback[message]', :with => message
  fill_in 'feedback[subject]', :with => subj
  click_button 'Send'
end

feature 'Visitor wants to send feedback' do
  let(:subject) { page }
  before(:each) {
    @user = FactoryGirl.create(:user, :username => 'user', :password => 'password')
  }

  describe 'with logged in user' do
    before {
      login_as(@user, :as => :user)
      visit new_feedback_path
    }

    it { should have_selector('#feedback_from', visible: false) }

    context 'sending the form' do
      let(:message) { 'Lá nas minhas Minas Gerais' }
      let(:subject) { 'A vida é boa' }

      before { send_feedback subject, message }

      context 'with valid fields' do
        it { current_path.should eq(new_feedback_path) }
        it { has_success_message t('feedback.create.success') }
      end

      context 'without message' do
        let(:message) { '' }

        it { current_path.should eq(new_feedback_path) }
        it { has_failure_message t('feedback.create.fill_fields') }
      end

      context 'without subject' do
        let(:subject) { '' }

        it { current_path.should eq(new_feedback_path) }
        it { has_failure_message t('feedback.create.fill_fields') }
      end

    end

  end

  context 'with logged out user' do
    before { visit new_feedback_path }

    it { should have_selector('#feedback_from', visible: true) }

    context 'sending the form' do
      let(:message) { 'Lá nas minhas Minas Gerais' }
      let(:subject) { 'A vida é boa' }
      let(:email) { 'ahehsenhor@minas.org.br' }

      before { send_feedback subject, message, email }

      context 'with valid fields' do
        it { current_path.should eq(new_feedback_path) }
        it { has_success_message t('feedback.create.success') }
      end

      context 'without message' do
        let(:message) { '' }

        it { current_path.should eq(new_feedback_path) }
        it { has_failure_message t('feedback.create.fill_fields') }
      end

      context 'without subject' do
        let(:subject) { '' }

        it { current_path.should eq(new_feedback_path) }
        it { has_failure_message t('feedback.create.fill_fields') }
      end

      context 'without email' do
        let(:email) { '' }

        it { current_path.should eq(new_feedback_path) }
        it { has_failure_message t('feedback.create.check_mail') }
      end

      context 'with invalid email' do
        let(:email) { '@@@@aaas' }

        it { current_path.should eq(new_feedback_path) }
        it { has_failure_message t('feedback.create.check_mail') }
      end
    end
  end
end
