module MwebEvents
  module ParticipantsHelper

    def build_message_path(participant)
       main_app.new_message_path(
        :user_id => current_user.to_param, :receiver => participant.owner.id,
        :private_message => { :title => t('mweb_events.participants.index.event', :event => participant.event.name) }
       )
    end

  end
end