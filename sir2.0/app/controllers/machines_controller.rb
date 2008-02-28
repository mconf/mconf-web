class MachinesController < ApplicationController
  # GET /machines
  # GET /machines.xml
   before_filter :authorize
  def index
    manage_resources
  end

def contact_mail  
  #no hace nada
end
  
  #this method is used in the contact form used to ask for more resources. This check some params
def my_mailer     
    from_email = params[:comment][:email]  
      message = params[:comment][:message]  
 begin
 #First check if the senders email is valid
   if from_email =~ /^[a-zA-Z0-9._%-]+@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,4}$/
     #put all the contents of my form in a hash
     mail_info = {"from_name" => current_user.login,"user_email" => current_user.email, "from_email" => from_email, "message" => message}
    #Call the Notifier class and send the email
    Notifier.deliver_contact_mail(mail_info)
     #Display a message notifying the sender that his email was delivered.
    flash[:notice] = 'Your message was successfully delivered to the SIR Administrator.'
    #Then redirect to index or any page you want with the message
    redirect_to(:action => 'list_user_machines')  
  else
 #if the senders email address is not valid
 #display a warning and redirect to any action you want
    flash[:warning] = 'Your email address appears to be invalid.'
    redirect_to(:action => 'contact_mail')
 end  
 rescue
 #if everything fails, display a warning and the exception
#Maybe not always advisable if your app is public
#But good for debugging, especially if action mailer is setup wrong
 flash[:warning] = "Your message could not be delivered at this time. #$!. Please try again later"
 redirect_to(:action => 'list_user_machines') end
   end

def list_user_machines 
  current_user.machines 
end

  # GET /machines/1
  # GET /machines/1.xml
  def show
    @machine = Machine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @machine }
    end
  end


  # GET /machines/new
  # GET /machines/new.xml
  def new
    @machine = Machine.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @machine }
    end
  end


  # GET /machines/1/edit
  def edit
    @machine = Machine.find(params[:id])
  end


  # POST /machines
  # POST /machines.xml
  def create
    @machine = Machine.new(params[:machine])

    respond_to do |format|
      if @machine.save
        flash[:notice] = 'Machine was successfully created.'
        format.html { redirect_to(@machine) }
        format.xml  { render :xml => @machine, :status => :created, :location => @machine }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @machine.errors, :status => :unprocessable_entity }
      end
    end
  end


  # PUT /machines/1
  # PUT /machines/1.xml
  def update
    @machine = Machine.find(params[:id])

    respond_to do |format|
      if @machine.update_attributes(params[:machine])
        flash[:notice] = 'Machine was successfully updated.'
        format.html { redirect_to(@machine) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @machine.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /machines/1
  # DELETE /machines/1.xml
  def destroy
    @machine = Machine.find(params[:id])
    @machine.destroy

    respond_to do |format|
      format.html { redirect_to(machines_url) }
      format.xml  { head :ok }
    end
  end
  
  #used for a administrator in order to manage user
  def manage_resources
    #test if the user that request the change is superuser
    if current_user.superuser!=true              
      logger.error("ERROR: ATTEMPT TO MANAGE RESOURCES WITHOUT BEING SUPERUSER/ADMIN")
      logger.error("USER WAS: " + current_user.login)
      flash[:notice] = "Action not allowed"
      redirect_to(:action => "index", :controller => "home")
      return false
    end    
    @machines = Machine.find(:all)
    #breakpoint()
    if params[:myaction] && params[:myaction]=="delete"
      delete_resource
      return
    elsif params[:myaction] && params[:myaction]=="add"
      add_resource
      return
    elsif params[:myaction] && params[:myaction]=="edit"
      edit_resource
      return
    elsif params[:myaction] && params[:myaction]=="assign_to_all"
      assign_to_everybody  #method to assign the resource to everybody
      return
    end
    respond_to do |format|
      format.html {render :action => 'list_resources'} # list.rhtml
      format.xml  { render :xml => @machines }
    end
  end
  
  
  def add_resource
    #test if the user that request the change is superuser
   if current_user.superuser!=true                    
      logger.error("ERROR: ATTEMPT TO ADD RESOURCES WITHOUT BEING SUPERUSER/ADMIN")
      logger.error("USER WAS: " + current_user.login)
      flash[:notice] = "Action not allowed"
      redirect_to(:action => "index", :controller => "home")
      return false
    end    
     name = params[:name_to_add]
     nickname = params[:nick_to_add]
     if name==nil || nickname==nil  || name=="" || nickname ==""      
        @machines = Machine.find(:all)
        flash[:notice] = "Nor name or nickname can be blank"
        render(:partial => "add_resource", :layout => false) 
        return false
     end
     if Machine.find_by_name(name)
          #already exists
          flash[:notice] = "Name exist"
          @machines = Machine.find(:all)
          redirect_to(:action => 'manage_resources') 
          return false     
     end
     if Machine.find_by_nickname(nickname)
          #already exists
          flash[:notice] = "Resource Full Name exist"
          @machines = Machine.find(:all)
          redirect_to(:action => 'manage_resources') 
          return false     
     end
       @machine = Machine.new
       @machine.name = name
       @machine.nickname = nickname
       @machine.save   
       @machines = Machine.find(:all)
       #Now we create the file that will be used for the connect to
       fh = File.new("resource_files/" + name + ".icto" , "w")
       fh.puts "isabel://" + nickname
       fh.close
       logger.debug("Fichero " + name + ".icto creado para uso futuro")
       
       redirect_to(:action => 'manage_resources')     
  end


  def edit_resource
    #test if the user that request the change is superuser
    if current_user.superuser!=true              
      logger.error("ERROR: ATTEMPT TO EDIT RESOURCES WITHOUT BEING SUPERUSER/ADMIN")
      logger.error("USER WAS: " + current_user.login)
      flash[:notice] = "Action not allowed"
      redirect_to(:action => "index", :controller => "home")
      return false
    end    
    name = params[:name_to_add]
    nickname = params[:nick_to_add]     
    if name==nil || nickname==nil  || name=="" || nickname ==""      
        @machines = Machine.find(:all)
        flash[:notice] = "Nor name or nickname can be blank"
        redirect_to(:action => 'manage_resources') 
        return false
    end
    #the nick can't be repeated
    @resources_repeated = Machine.find_all_by_name(params[:name_to_add])
    if @resources_repeated.length > 1 || (@resources_repeated[0]!=nil && @resources_repeated[0].id!=params[:resource_id_to_edit].to_i)
        @machines = Machine.find(:all)
        flash[:notice] = "Nickname already in use"
        redirect_to(:action => 'manage_resources')
        return false
    end
    #the nick can't be repeated
    @resources_repeated = Machine.find_all_by_nickname(params[:nick_to_add])
    
    if @resources_repeated.length > 1 || (@resources_repeated[0]!=nil && @resources_repeated[0].id!=params[:resource_id_to_edit].to_i)
        @machines = Machine.find(:all)
        flash[:notice] = "Full name already in use"
        redirect_to(:action => 'manage_resources')
        return false
    end
    
    @machines = Machine.find(:all)
    resource_to_edit = @machines[params[:index_to_edit].to_i-1]
    #if the name changes we have to create a new icto file and delete the old one
    name_changed = false
    if resource_to_edit.name != params[:name_to_add]
      name_changed = true
      old_name = resource_to_edit.name
    end
    resource_to_edit.name = params[:name_to_add]
    resource_to_edit.nickname = params[:nick_to_add]
    resource_to_edit.save
    #now we have to change the file icto that the user needs to do the connect to
    if name_changed
      if File.exist?("resource_files/" + old_name + ".icto")
          FileUtils.rm "resource_files/" + old_name + ".icto"
          logger.debug("Borrado el fichero icto de resource_files")
       end
    end
    fh = File.new("resource_files/" + params[:name_to_add] + ".icto" , "w")
    fh.puts "isabel://" + params[:nick_to_add]
    fh.close
    @machines = Machine.find(:all)
    flash[:notice] = "Resource edited successfully."
    redirect_to(:action => 'manage_resources') 
  end


  def delete_resource
     #test if the user that request the change is superuser
    if current_user.superuser!=true             
      logger.error("ERROR: ATTEMPT TO DELETE RESOURCES WITHOUT BEING SUPERUSER/ADMIN")
      logger.error("USER WAS: " + current_user.login)
      flash[:notice] = "Action not allowed"
      redirect_to(:action => "index", :controller => "event")
      return false
    end    
     name = params[:resource_to_delete]
     resource_to_delete = Machine.find_by_name(name)
     resource_to_delete.destroy
     if File.exist?("resource_files/" + resource_to_delete.name + ".icto")
          FileUtils.rm "resource_files/" + resource_to_delete.name + ".icto"
          logger.debug("Borrado el fichero icto de resource_files")
     end
     @machines = Machine.find(:all)
     redirect_to(:action => 'manage_resources')  
   end
  
  
  #method to assign the resource to everybody
  def assign_to_everybody
    resource_id = params[:resource_id_to_edit]
    resource_to_assign = Machine.find_by_id(resource_id)
    
    resource_to_assign.users = Array.new #no vale sólo con la linea siguiente porque duplica los usuarios
    resource_to_assign.users << User.find(:all)    
    resource_to_assign.save
    flash[:notice] = "Resource assigned to everybody"
    @machines = Machine.find(:all)
    redirect_to(:action => 'manage_resources')  
    
  end
  def get_file   
      machines = []
      machines = Machine.find(:all)
      for machine in machines
        if params["machine"].eql?(machine.name)        
          send_file("resource_files/" + machine.name + ".icto", :type => "application/isabel" )
          logger.debug("Archivo enviado: " + "machine_files" + machine.name + ".icto")
          return
        end
      end
    end
  
end
