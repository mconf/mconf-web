# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

MwebEvents::Participant.class_eval do
  include PublicActivity::Common
  has_one :participant_confirmation

  # create a ParticipantConfirmation request if no user is associated with the participation
  after_create :create_participant_confirmation, if: :annonymous?

  def annonymous?
    !owner.present?
  end

  # If a user has a confirmation request, return that value. If it has none, the user is confirmed
  def email_confirmed?
    if participant_confirmation.present?
      participant_confirmation.confirmed?
    else
      true
    end
  end

  def new_activity key, user
    create_activity key, :owner => owner, :parameters => { :user_id => user.try(:id), :username => user.try(:name) }
  end
end

MwebEvents::EventsHelper.class_eval do
  def build_message_path(participant)
    main_app.new_message_path(
      :user_id => current_user.to_param, :receiver => participant.owner.id,
      :private_message => { :title => t('mweb_events.participants.index.event', :event => participant.event.name) }
    )
  end
end
