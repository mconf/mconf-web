# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

def send_feedback subj, message, email=nil
  fill_in 'feedback[from]', :with => email if email.present?
  fill_in 'feedback[message]', :with => message
  fill_in 'feedback[subject]', :with => subj
  click_button 'Send'
end

feature 'Sending a feedback' do
  let(:subject) { page }

  describe 'as a signed in user' do
    before {
      @user = FactoryGirl.create(:user, :username => 'user', :password => 'password')
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

  context 'as an anonymous user' do
    before { visit new_feedback_path }
    it_behaves_like 'it redirects to login page'
    it { should_not have_selector('#feedback_from') }
  end
end
