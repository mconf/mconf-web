class MachinesController < ApplicationController  
   before_filter :authentication_required, :except => [:get_file, :list_user_machines, :contact_mail]
   before_filter :user_is_admin, :except => [:get_file, :list_user_machines, :contact_mail]
   
  # GET /machines
  # GET /machines.xml
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

  
  #used for a administrator in order to manage user
  def manage_resources  
    @machines = Machine.find(:all)
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
       flash[:notice] = "Resource successfully added"
       #Now we create the file that will be used for the connect to
       fh = File.new("resource_files/" + name + ".icto" , "w")
       fh.puts "isabel://" + nickname
       fh.close
       logger.debug("Fichero " + name + ".icto creado para uso futuro")
       
       redirect_to(:action => 'manage_resources')     
  end


  def edit_resource 
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
     name = params[:resource_to_delete]
     resource_to_delete = Machine.find_by_name(name)
     resource_to_delete.destroy
     if File.exist?("resource_files/" + resource_to_delete.name + ".icto")
          FileUtils.rm "resource_files/" + resource_to_delete.name + ".icto"
          logger.debug("Borrado el fichero icto de resource_files")
     end
     @machines = Machine.find(:all)
     flash[:notice] = "Resource deleted successfully."
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
