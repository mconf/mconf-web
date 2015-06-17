# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

MwebEvents::EventsController.class_eval do

  before_filter :block_if_events_disabled
  before_filter :custom_loading, only: [:index]
  before_filter :find_or_create_participant, only: [:show]

  after_filter only: [:create, :update] do
    @event.new_activity params[:action], current_user unless @event.errors.any?
  end

  def invite
    render layout: false if request.xhr?
  end

  def send_invitation
    if params[:invite][:title].blank?
      flash[:error] = t('mweb_events.events.send_invitation.error_title')

    elsif params[:invite][:users].blank?
      flash[:error] = t('mweb_events.events.send_invitation.blank_users')

    else
      invitations = EventInvitation.create_invitations params[:invite][:users],
        sender: current_user,
        target: @event,
        title: params[:invite][:title],
        url: @event.full_url,
        description: params[:invite][:message],
        ready: true

      # we do a check just to give a better response to the user, since the invitations will
      # only be sent in background later on
      succeeded, failed = EventInvitation.check_invitations(invitations)
      flash[:success] = EventInvitation.build_flash(
        succeeded, t('mweb_events.events.send_invitation.success')) unless succeeded.empty?
      flash[:error] = EventInvitation.build_flash(
        failed, t('mweb_events.events.send_invitation.error')) unless failed.empty?
    end
    redirect_to request.referer
  end

  # Load the participant from db if user is already registered or build a new one for the form
  def find_or_create_participant
    if current_user
      attrs = { email: current_user.email, owner: current_user, event: @event }
      @participant = MwebEvents::Participant.where(attrs).try(:first) || MwebEvents::Participant.new(attrs)
    end
  end

  # return 404 for all Event routes if the events are disabled
  def block_if_events_disabled
    unless Mconf::Modules.mod_enabled?('events')
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def custom_loading
    # Filter events for the current user
    if params[:my_events]
      if current_user
        @events = current_user.events
      else # Remove the parameter if no user is logged
        redirect_to events_path(params.except(:my_events))
        return
      end
    end

    # Filter events belonging to spaces or users with disabled status
    without_spaces = @events.where(owner_type: 'Space').joins('INNER JOIN spaces ON owner_id = spaces.id').where("spaces.disabled = ?", false)
    without_users = @events.where(owner_type: 'User').joins('INNER JOIN users ON owner_id = users.id').where("users.disabled = ?", false)
    # If only there was a conjunction operator that returned an AR relation, this would be easier
    # '|'' is the only one that corretly combines these two queries, but doesn't return a relation
    @events = MwebEvents::Event.where(id: (without_users | without_spaces))
    @events = @events.accessible_by(current_ability, :index).page(params[:page])
  end

  def handle_access_denied(exception)
    if @event.nil? || @event.owner.nil?
      raise ActiveRecord::RecordNotFound
    else
      raise exception
    end
  end

  def set_date_locale
    @date_locale = get_user_locale(current_user)
    @date_format = I18n.t('_other.datetimepicker.format')
    @event.date_stored_format = I18n.t('_other.datetimepicker.format_rails')
    @event.date_display_format = I18n.t('_other.datetimepicker.format_display')
  end

end
