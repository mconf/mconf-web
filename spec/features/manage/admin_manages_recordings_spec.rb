# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'
include DatesHelper

describe 'Admin manages recordings' do
  subject { page }

  shared_examples_for "it should have recording description" do
    it { should have_content(recording.name) }
    it { should have_content(recording.description) }
    it { should have_content(recording.recordid) }
    it { should have_content(I18n.l(Time.at(recording.start_time), format: :numeric)) }
    it { should have_content(recording.room.name) }
  end

  context 'with one recording set to represent each scenario' do

    let(:admin) { User.first } # admin is already created
    before {
      Site.current.update_attributes(require_registration_approval: true)

      login_as(admin, :scope => :user)
      @has_playback_rec = FactoryGirl.create(:bigbluebutton_playback_format, recording: FactoryGirl.create(:bigbluebutton_recording, name: 'has_playback_rec')).recording
      @published_rec = FactoryGirl.create(:bigbluebutton_recording, name: 'published_rec')
      @unpublished_rec = FactoryGirl.create(:bigbluebutton_recording, name: 'unpublished_rec', published: false)
      @unavailable_rec = FactoryGirl.create(:bigbluebutton_recording, name: 'unavailable_rec', available: false)
      @no_playback_rec = FactoryGirl.create(:bigbluebutton_recording, name: 'no_playback_rec')
    }

    context 'listing recordings in management screen' do
      before { visit manage_recordings_path }

      it { should have_css '.list-item', :count => 5 }
      it { should have_css '.icon-delete', :count => 5 }

      it { should have_css '.recording-not-available-name', :count => 1 }

      it { should have_css '.icon-edit', :count => 5 }
      it { should have_css '.icon-publish', :count => 1 }
      it { should have_css '.icon-unpublish', :count => 3 }
      skip { should have_css '.icon-list.enabled', :count => 1 } # TODO: show playbacks icon
      skip { should have_css '.icon-list.disabled', :count => 3 } # TODO: show playbacks icon

      context "recording with playback contains" do
        let(:recording) {@has_playback_rec}
        it_should_behave_like "it should have recording description"
      end

      context "recording with no playback contains" do
        let(:recording) {@no_playback_rec}
        it_should_behave_like "it should have recording description"
      end

      context "recording published contains" do
        let(:recording) {@published_rec}
        it_should_behave_like "it should have recording description"
      end

      context "recording unpublished contains" do
        let(:recording) {@unpublished_rec}
        it_should_behave_like "it should have recording description"
      end

      context "recording unavailable contains" do
        let(:recording) {@unavailable_rec}
        it_should_behave_like "it should have recording description"
      end

      # TODO: reenable playback types
      skip 'elements for a recording with playback' do
        let(:recording) { @has_playback_rec }
        subject { page.find("#recording-#{recording.id}") }

        it { should have_css '.icon-edit' }
        it { should have_css '.icon-unpublish' }
        it { should have_css '.icon-delete' }
        it { should have_css '.icon-list.enabled' }
        it { should have_link_to_edit_bigbluebutton_recording(recording) }
        it { should have_link_to_unpublish_bigbluebutton_recording(recording) }
        it { should have_link_to_delete_bigbluebutton_recording(recording) }
        it { should have_link_to_showplayback_bigbluebutton_recording(recording) }
        it do
          recording.playback_formats.each do |playback|
           should have_link_to_playbacks(playback)
          end
        end
      end

      context 'elements for a recording with no playback' do
        let(:recording) { @no_playback_rec }
        subject { page.find("#recording-#{recording.recordid}") }

        it { should have_css '.icon-edit' }
        it { should have_css '.icon-unpublish' }
        it { should have_css '.icon-delete' }
        skip { should have_css '.icon-list.disabled' } # TODO
        it { should have_link_to_edit_bigbluebutton_recording(recording) }
        it { should have_link_to_unpublish_bigbluebutton_recording(recording) }
        it { should have_link_to_delete_bigbluebutton_recording(recording) }
        skip { should_not have_link_to_showplayback_bigbluebutton_recording(recording) } # TODO
        skip { expect(recording.playback_formats).to be_empty } # TODO
      end

      context 'elements for a published recording' do
        let(:recording) { @published_rec }
        subject { page.find("#recording-#{recording.recordid}") }

        it { should have_css '.icon-edit' }
        it { should have_css '.icon-unpublish' }
        it { should have_css '.icon-delete' }
        skip { should have_css '.icon-list.disabled' } # TODO
        it { should have_link_to_edit_bigbluebutton_recording(recording) }
        it { should have_link_to_unpublish_bigbluebutton_recording(recording) }
        it { should have_link_to_delete_bigbluebutton_recording(recording) }
        skip { should_not have_link_to_showplayback_bigbluebutton_recording(recording) } # TODO
        skip { expect(recording.playback_formats).to be_empty } # TODO
      end

      context 'elements for an unpublished recording' do
        let(:recording) { @unpublished_rec }
        subject { page.find("#recording-#{recording.recordid}") }

        it { should have_css '.icon-edit' }
        it { should have_css '.icon-publish' }
        it { should have_css '.icon-delete' }
        skip { should have_css '.icon-list.disabled' } # TODO
        it { should have_link_to_edit_bigbluebutton_recording(recording) }
        it { should have_link_to_publish_bigbluebutton_recording(recording) }
        it { should have_link_to_delete_bigbluebutton_recording(recording) }
        skip { should_not have_link_to_showplayback_bigbluebutton_recording(recording) } # TODO
        skip { expect(recording.playback_formats).to be_empty } # TODO
      end

      context 'elements for an unavailable recording' do
        let(:recording) { @unavailable_rec }
        subject { page.find("#recording-#{recording.recordid}") }

        it { should have_css '.icon-edit' }
        it { should have_css '.icon-delete' }
        it { should_not have_css '.icon-list' }
        it { should have_link_to_edit_bigbluebutton_recording(recording) }
        it { should have_link_to_delete_bigbluebutton_recording(recording) }
        skip { should_not have_link_to_showplayback_bigbluebutton_recording(recording) } # TODO
      end

    end
  end
end

def have_link_to_edit_bigbluebutton_recording(recording)
  have_link '', :href => edit_bigbluebutton_recording_path(recording)
end

def have_link_to_unpublish_bigbluebutton_recording(recording)
  have_css("a[href='#{unpublish_bigbluebutton_recording_path(recording)}'][data-method='post']")
end

def have_link_to_publish_bigbluebutton_recording(recording)
  have_css("a[href='#{publish_bigbluebutton_recording_path(recording)}'][data-method='post']")
end

def have_link_to_delete_bigbluebutton_recording(recording)
  have_css("a[href='#{bigbluebutton_recording_path(recording, :redir_url => manage_recordings_path)}'][data-method='delete']")
end

def have_link_to_showplayback_bigbluebutton_recording(recording)
  have_css("a.showplayback")
end

#TODO test with more than one playback format and making one fail to make sure the loop fails
def have_link_to_playbacks(playback)
  have_css("a[href='#{play_bigbluebutton_recording_path(playback.recording, type: playback.format_type) }']")
end
