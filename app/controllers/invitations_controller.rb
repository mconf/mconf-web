class InvitationsController < ApplicationController
  before_filter :needs_space

  # Capar todas las acciones del controlador del plugin, menos las redefinidas aqui
  authorization_filter :current_site, :update, :except => [ :new, :create ]
  authorization_filter :space, [ :create, :Performance ], :only   => [ :new ]
  before_filter :create_invitation_authorization_filter, :only => [ :create ]

  def new
    session[:current_sub_tab] = "Add Users by email"
  end

  def create
    #parsear string de emails y hacer todo lo de abajo para cada email.
    session[:current_sub_tab] = "Add Users by email"

    unless params[:email_list] && params[:email_list].present? && params[:role]
      flash[:notice] = "Please insert something in the box"      
      render :action => 'new'
      return
    end

    role = Space.roles.find{ |r| r.name == params[:role]}
    unless role
      flash[:error] = "Role invalid: #{ params[:role] }"
      render :action => :new
      return
    end
     
    @parse_email = /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
    emails = params[:email_list].split(Invitation::DELIMITER).map{ |email|
      email.strip.squeeze(" ") 
    }.flatten.compact.map(&:downcase).uniq

    @users_invited = []
    @users_added = []
    @users_not_added = []
    @emails_invalid = []

    emails.each do |raw_email|
      p = /\S+@\S+\.\S+/
      email = p.match(raw_email).to_s
      email = email.gsub(/>/,' ')
      email = email.gsub(/</,' ')
      email = p.match(email).to_s

      if @parse_email.match(email)
        user = User.find_by_email(email)
        if user
          performance = @space.stage_performances.find_by_agent_id_and_agent_type(user.id, "User")
          if performance
            #el usuraio ya esta en el esapcio
            @users_not_added << email
          else
            @space.stage_performances.create :agent => user, 
                                             :role => role
            #esta en el sir pero no en el espacio, no añado a la tabla le añado al espacio y le notifico pro mail
            @users_added << email
            #falta notificar por mail
          end
        else
          Invitation.create! :email => email,
                             :stage => @space,
                             :agent => current_user,
                             :role => role
                            
          @users_invited << email
          #falta notificar por mail
        end
      else
        @emails_invalid << raw_email 
      end
    end

    respond_to do |format|
      format.html
    end
  end

  private

  def needs_space
    @space = Space.find_by_name(params[:space_id])

    unless @space 
      flash[:error] = "Space not provided"
      redirect_to(root_path)
    end 
  end

  def create_invitation_authorization_filter
    return if authenticated? && current_agent.superuser?

    if authorized?(:space, [ :create, :Performance ])
      if params[:role] == 'Admin' && !@space.role_for?(current_user, :name => 'Admin')
        flash[:error] = "You can't invite Admin users"
        redirect_to new_space_invitation_path(@space)
      end
    else
      not_authorized
    end
  end
end
