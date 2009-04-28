class AdmissionsController < ApplicationController
  before_filter :space!
  authorization_filter [ :create, :performance ], :space

  def index
    respond_to do |format|
      format.html
    end
  end

  def invitations
    @invitations = params[:invitation][:email].split(',').map(&:strip).map { |email|
      space.invitations.build params[:invitation].update(:email => email)
    }.each(&:save)

    respond_to do |format|
      format.html { 
        render :action => :index
      }
    end

  end

end
