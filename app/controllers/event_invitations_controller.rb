class EventInvitationsController < ApplicationController
  before_filter :invitation, :only => [ :show, :update, :delete ]
  before_filter :candidate_authenticated, :only => [ :show, :update ]

  # GET /event_invitations
  # GET /event_invitations.xml
  def index
    @invitations = group ?
      group.invitations.column_sort(params[:order], params[:direction]) :
      Invitation.column_sort(params[:order], params[:direction])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invitations }
    end
  end

  # GET /event_invitations/1
  # GET /event_invitations/1.xml
  def show
    unless @invitation
      flash[:error] = t('invitation.not_found')
      redirect_to root_path
      return
    end

    respond_to do |format|
      format.html {
        @candidate = User.new
      }
      format.xml  { render :xml => @invitation }
    end
  end

  def create
    @invitation = ( group.try(:invitations) || Invitation ).new params[:invitation]
    @invitation.introducer = current_agent

    if @invitation.save
      flash[:success] = t('invitation.created')
    else
      flash[:error] = @invitation.errors.to_xml
    end

    redirect_to(request.referer || [ group, Invitation.new ])
  end

  # PUT /event_invitations/1
  # PUT /event_invitations/1.xml
  def update
    unless authenticated?
      # To update an Invitation, we require always Authentication.
      #
      # The agent may register or signup with her account, due to other email.
      klass = ActiveRecord::Agent::Invite.classes.first

      # We first try to authenticate the credentials
      # TODO: other authentication methods like OpenID
      @candidate = params[klass.to_s.underscore].present? ?
        klass.authenticate_with_login_and_password(params[klass.to_s.underscore][:login],
                                                   params[klass.to_s.underscore][:password]) :
        nil

      if @candidate.blank?
        # If agent is not authenticated, try to register
        @candidate = klass.new(params[klass.to_s.underscore])
        @candidate.email = invitation.email
        # Agent has read the invitation email, so it's already activated
        @candidate.activated_at = Time.now if @candidate.agent_options[:activation]
        
        unless @candidate.save
          render :action => :show
          return
        end
      end

      # Authenticate Agent
      self.current_agent = @candidate

      # invitation.candidate should have changed, explicity or due to current_agent callback
      invitation.reload
    end

    respond_to do |format|
      if invitation.update_attributes(params[:event_invitation])
        format.html {
          flash[:success] = invitation.state_message
          redirect_to(space_event_path(invitation.group, Event.find(invitation.event_id)) || root_path)
        }
      else
        format.html { render :action => :show }
      end
    end
  end

  # DELETE /event_invitations/1
  # DELETE /event_invitations/1.xml
  def destroy
    invitation.destroy

    respond_to do |format|
      format.html { redirect_to(request.referer || [ invitation.group, Invitation.new ]) }
      format.xml  { head :ok }
    end
  end

  private

  def group
    @group ||= record_from_path(:acts_as => :stage)
  end

  def invitation
    @invitation ||= EventInvitation.find_by_code(params[:id]) || raise(ActiveRecord::RecordNotFound, "Event invitation not found")
  end

  def candidate_authenticated
    not_authenticated if invitation.candidate && ! authenticated?
  end
end
