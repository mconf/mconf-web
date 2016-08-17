# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ParticipantConfirmationsController < ApplicationController

  before_filter :find_by_token

  def confirm
    @pc.confirm!
    redirect_to event_path(@pc.participant.event), notice: t('participant_confirmation.confirmed', email: @pc.participant.email)
  end

  def destroy
    @pc.destroy
    redirect_to event_path(@pc.participant.event), notice: t('participant_confirmation.cancelled')
  end

  private
  def find_by_token
    @pc = ParticipantConfirmation.where(token: params[:token]).first
  end
end
