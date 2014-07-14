MwebEvents::Participant.class_eval do
  include PublicActivity::Common

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
