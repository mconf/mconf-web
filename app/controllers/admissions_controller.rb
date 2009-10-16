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
      if space.actors.map{|a| a.email} && space.actors.map{|a| a.email}.include?(email)
        #the user is already in the space
        flash[:notice] = email + " " + t('invitation.not_created')
        next
      end
      if space.invitations.map{|a| a.email} && space.invitations.map{|a| a.email}.include?(email)
        #the user is already invited to the space
        flash[:notice] = email + " " + t('invitation.not_created_2')
        next
      end
      
      i = space.invitations.build params[:invitation].update(:email => email)
      i.introducer = current_user
      i
    }.compact.each(&:save)

    respond_to do |format|
      format.html { 
        render :action => :index
      }
    end

  end

end
