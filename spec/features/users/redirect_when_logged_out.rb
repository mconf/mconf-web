require 'spec_helper'
require 'support/feature_helpers'

feature 'Logged out user is' do

  context 'redirected to login page' do
    let(:user) { FactoryGirl.create(:user) }
    subject { page }

    # context 'on show' do
    #   before { visit user_path(user) }
    #   it_behaves_like 'it redirects to login page'
    # end

    context 'on edit' do
      before { visit edit_user_path(user) }
      it_behaves_like 'it redirects to login page'
    end

    # context 'on approve' do
    #   before { visit approve_user_path(user_pather) }
    #   it_behaves_like 'it redirects to login page'
    # end

    # context 'on disapprove' do
    #   before { visit disapprove_user_path(user) }
    #   it_behaves_like 'it redirects to login page'
    # end

    # context 'on enable' do
    #   before { visit enable_user_path(user) }
    #   it_behaves_like 'it redirects to login page'
    # end

    # context 'on disable' do
    #   before { visit disable_user_path(user) }
    #   it_behaves_like 'it redirects to login page'
    # end

  end


end
