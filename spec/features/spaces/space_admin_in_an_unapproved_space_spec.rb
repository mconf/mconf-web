# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

describe 'Space admin in an unapproved space' do
  subject { page }

  context "should not see these links" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations, approved: false, repository: true) }

    before {
      Site.current.update_attributes(require_space_approval: true)
      space.add_member!(user, 'Admin')
      sign_in_with user.email, user.password
    }

    context "on the space menu" do
      before { visit space_path(space) }

      it { should have_link('', href: space_path(space)) }
      it { should_not have_link('', href: webconference_space_path(space)) }
      it { should_not have_link('', href: space_posts_path(space)) }
      it { should_not have_link('', href: space_events_path(space)) }
      it { should have_link('', href: space_users_path(space)) }
      it { should_not have_link('', href: space_attachments_path(space)) }
      it { should have_link('', href: edit_space_path(space)) }
    end

    context "on the admin menu" do
      before { visit edit_space_path(space) }

      it { should have_link('', href: edit_space_path(space)) }
      it { should_not have_link('', href: invite_space_join_requests_path(space)) }
      it { should_not have_link('', href: space_join_requests_path(space)) }
      it { should_not have_link('', href: user_permissions_space_path(space)) }
      it { should_not have_link('', href: webconference_options_space_path(space)) }
    end

  end

  context "make sure an admin on an approved space sees all the links" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations, approved: true, repository: true) }

    before {
      space.add_member!(user, 'Admin')
      sign_in_with user.email, user.password
    }

    context "on the space menu" do
      before { visit space_path(space) }

      it { should have_link('', href: space_path(space)) }
      it { should have_link('', href: webconference_space_path(space)) }
      it { should have_link('', href: space_posts_path(space)) }
      it { should have_link('', href: space_events_path(space)) }
      it { should have_link('', href: space_users_path(space)) }
      it { should have_link('', href: space_attachments_path(space)) }
      it { should have_link('', href: edit_space_path(space)) }
    end

    context "on the admin menu" do

      before { visit edit_space_path(space) }

      it { should have_link('', href: edit_space_path(space)) }
      it { should have_link('', href: invite_space_join_requests_path(space)) }
      it { should have_link('', href: space_join_requests_path(space)) }
      it { should have_link('', href: user_permissions_space_path(space)) }
      it { should have_link('', href: webconference_options_space_path(space)) }
    end


  end

end
