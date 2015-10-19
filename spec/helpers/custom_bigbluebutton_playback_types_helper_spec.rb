# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

include ApplicationHelper

describe CustomBigbluebuttonPlaybackTypesHelper do

  describe "#link_to_playback" do
    let(:recording) { FactoryGirl.create(:bigbluebutton_recording) }
    let(:presentation) { FactoryGirl.create(:bigbluebutton_playback_type, identifier: "presentation") }
    let(:presentation_export) { FactoryGirl.create(:bigbluebutton_playback_type, identifier: "presentation_export") }
    let(:presentation_video) { FactoryGirl.create(:bigbluebutton_playback_type, identifier: "presentation_video") }

    context "when the identifier was presentation" do
      let(:playback) { FactoryGirl.create(:bigbluebutton_playback_format, playback_type: presentation) }
      let!(:link) { link_to playback.name, play_bigbluebutton_recording_path(recording, type: presentation.identifier), options_for_tooltip(t("bigbluebutton_rails.playback_types.presentation.tip")) }

      subject { link_to_playback(recording, playback) }

      it("returns the correctly link") { should eq(link) }
    end

    context "when the identifier was presentation_export" do
      let(:playback) { FactoryGirl.create(:bigbluebutton_playback_format, playback_type: presentation_export) }
      let!(:link) { link_to playback.name, play_bigbluebutton_recording_path(recording, type: presentation_export.identifier), options_for_tooltip(t("bigbluebutton_rails.playback_types.presentation_export.tip")) }

      subject { link_to_playback(recording, playback) }

      it("returns the correctly link") { should eq(link) }
    end

    context "when the identifier was presentation_video" do
      let(:playback) { FactoryGirl.create(:bigbluebutton_playback_format, playback_type: presentation_video) }
      subject { link_to_playback(recording, playback) }

      before {
        recording.update_attributes(name: 'My recording name: 1', description: 'My recording description #1')
      }

      context 'and the description is set' do
        let(:name) { 'my_recording_description_1' }
        let(:link) { link_to playback.name, play_bigbluebutton_recording_path(recording, { type: presentation_video.identifier, name: name }), options_for_tooltip(t("bigbluebutton_rails.playback_types.presentation_video.tip"), { download: name }) }

        it("returns the correctly link") { should eq(link) }
      end

      context 'and the description is not set' do
        let(:name) { 'my_recording_name_1' }
        let(:link) { link_to playback.name, play_bigbluebutton_recording_path(recording, { type: presentation_video.identifier, name: name }), options_for_tooltip(t("bigbluebutton_rails.playback_types.presentation_video.tip"), { download: name }) }

        before { recording.update_attributes(description: nil) }

        it("returns the correctly link") { should eq(link) }
      end

      context 'and the description is empty' do
        let(:name) { 'my_recording_name_1' }
        let(:link) { link_to playback.name, play_bigbluebutton_recording_path(recording, { type: presentation_video.identifier, name: name }), options_for_tooltip(t("bigbluebutton_rails.playback_types.presentation_video.tip"), { download: name }) }

        before { recording.update_attributes(description: '') }

        it("returns the correctly link") { should eq(link) }
      end
    end
  end
end
