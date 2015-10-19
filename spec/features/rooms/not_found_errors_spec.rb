# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'Uses see the correct error for rooms that are not found' do

  context 'When the room exists' do
    let(:user) { FactoryGirl.create(:user) }
    let(:room) { FactoryGirl.create(:bigbluebutton_room, owner: user) }

    context "for actions that need extra information from the webconf server"  do
      before {
        BigbluebuttonRoom.any_instance.stub(:fetch_is_running?)
        visit join_bigbluebutton_room_path(room)
      }

      it { page.status_code.should == 200 }
      it { page.should have_content(room.name) }
    end

    context "for actions that don't need extra information from the webconf server"  do
      before { visit join_webconf_path(room) }

      it { page.status_code.should == 200 }
      it { page.should have_content(room.name) }
    end
  end

  context 'When the room does not exist' do
    context "for actions that need extra information from the webconf server"  do
      let(:url) { join_bigbluebutton_room_path(id: 'nonexistent') }
      before { visit url }

      it { page.status_code.should == 404 }
      it { page.should have_title(t('error.e404.title')) }
      it { page.should have_content(t('error.e404.title')) }
      it { page.should have_content(t('error.e404.description', url: url)) }
    end

    context "for actions that don't need extra information from the webconf server"  do
      let(:url) { join_webconf_path(id: 'nonexistent') }
      before { visit url }

      it { page.status_code.should == 404 }
      it { page.should have_title(t('error.e404.title')) }
      it { page.should have_content(t('error.e404.title')) }
      it { page.should have_content(t('error.e404.description', url: url)) }
    end
  end

end
