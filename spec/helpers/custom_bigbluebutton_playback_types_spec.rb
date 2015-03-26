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
      let!(:name) { recording.name.downcase.tr(" ", "_") }
      let!(:link) { link_to playback.name, play_bigbluebutton_recording_path(recording, { type: presentation_video.identifier, name: name }), options_for_tooltip(t("bigbluebutton_rails.playback_types.presentation_video.tip"), {download: name}) }

      subject { link_to_playback(recording, playback) }

      it("returns the correctly link") { should eq(link) }
    end
  end
end
