# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ParticipantConfirmationsController do
  render_views

  describe "#confirm" do
    let(:pc) { FactoryGirl.create(:participant, email: 'divine@wings.of').participant_confirmation }

    before {
      expect {
        get :confirm, token: pc.to_param
      }.to change { ParticipantConfirmation.where('confirmed_at is not null').count }.by(1)
    }

    it { pc.reload.should be_confirmed }
    it { should redirect_to(MwebEvents::Engine.routes.url_helpers.event_path(pc.participant.event)) }
    it { should set_the_flash.to(I18n.t('participant_confirmation.confirmed', email: pc.email)) }
  end

end