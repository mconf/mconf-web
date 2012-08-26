# -*- coding: utf-8 -*-
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

class InvitationsController < ApplicationController
  # TODO: permissions
  #authorization_filter :forbidden, :invitation, :only => [ :index ]

  #-#-# from station

  include ActionController::StationResources

  before_filter :introducer_authenticated, :only => [ :show ]
  before_filter :candidate_authenticated, :only => [ :show, :update ]

  before_filter :processed_invitation, :only => [ :show ]

  def create
    @invitation = ( group.try(:invitations) || Invitation ).new params[:invitation]
    @invitation.introducer = current_user

    if @invitation.save
      flash[:success] = t('invitation.created')
    else
      flash[:error] = @invitation.errors.to_xml
    end

    redirect_to(request.referer || [ group, Invitation.new ])
  end

  # PUT /invitations/1
  # PUT /invitations/1.xml
  def update
    # TODO: authentication
    # unless authenticated?
    #   # To update an Invitation, we require always Authentication.
    #   #
    #   # The agent may register or signup with her account, due to other email.
    #   klass = ActiveRecord::Agent::Invite.classes.first

    #   # We first try to authenticate the credentials
    #   # TODO: other authentication methods like OpenID
    #   @candidate = params[klass.to_s.underscore].present? ?
    #     klass.authenticate_with_login_and_password(params[klass.to_s.underscore][:login],
    #                                                params[klass.to_s.underscore][:password]) :
    #     nil

    #   if @candidate.blank?
    #     # If agent is not authenticated, try to register
    #     @candidate = klass.new(params[klass.to_s.underscore])
    #     @candidate.email = invitation.email
    #     # Agent has read the invitation email, so it's already activated
    #     @candidate.confirmed_at = Time.now

    #     unless @candidate.save
    #       render :action => :show
    #       return
    #     end
    #   end

    #   # Authenticate Agent
    #   sign_in @candidate, :bypass => true

    #   # invitation.candidate should have changed, explicity or due to sign_in
    #   invitation.reload
    # end


    invitation.attributes = params[:invitation]
    # Invitation may be accepted by an already registered user when sent to a different
    # email address
    invitation.candidate ||= current_user if params[:invitation][:processed]

    respond_to do |format|
      if invitation.save
        format.html {
          flash[:success] = invitation.state_message
          redirect_to(invitation.group || root_path)
        }
      else
        format.html { render :action => :show }
      end
    end
  end

  private

  def group
    @group ||= record_from_path(:acts_as => :stage)
  end

  def candidate_authenticated
    not_authenticated if invitation.candidate && ! user_signed_in?
  end

  def introducer_authenticated
    #TODO logout and redirect to invitation again
    redirect_to logout_path if invitation.introducer == current_user
  end

  def processed_invitation
    if invitation.processed?
      flash[:notice] = t(invitation.state, :scope => 'invitation.was_processed')
      redirect_to invitation.group
    end
  end

end
