# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

class EventInvitationsController < ApplicationController
  before_filter :invitation, :only => [ :show, :update, :delete, :get_show_params ]
  #before_filter :candidate_authenticated, :only => [ :update ]

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
    get_show_params
    respond_to do |format|
      format.html {
          @candidate = User.new
          render :action => "show"
      }
      format.xml  { render :xml => @invitation }
    end
  end

  def get_show_params
    unless @invitation
      flash[:error] = t('invitation.not_found')
      redirect_to root_path
      return
    end
    @event = Event.find(@invitation.event_id);
    @space = Space.find(@invitation.group_id);
    @assistants =  @event.participants.select{|p| p.attend == true}
    @no_assistants = @event.participants.select{|p| p.attend != true} 
    @not_responding_candidates = @event.event_invitations.select{|e| !e.candidate.nil? && !e.processed?}
    @not_responding_emails = @event.event_invitations.select{|e| e.candidate.nil? && !e.processed?}
  end
  
  
  # GET /event_invitations/new
  # GET /event_invitations/new.xml
  def new
    
  end
  
  #http://localhost:3000/event_invitations/0659ef4a97ca8d147c963f74a153d40409e6cc50
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
          get_show_params
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
