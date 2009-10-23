require 'vpim/vcard'

class ProfilesController < ApplicationController
  #before_filter :authentication_required

  before_filter :get_user
  
  #authorization_filter :read, :profile, :only => [ :show ]
  authorization_filter :manage, :profile, :except => [ :show ]

  before_filter :unique_profile, :only=> [:new, :create]
  
  # GET /profile
  # GET /profile.xml
  # if params[:hcard] then hcard is rendered
  def show
    @user_spaces = @user.spaces
    #The latest posts that the user has written in shared spaces with the current user 
    #@latest_posts= @user.posts.in_container(@user.spaces & current_user.spaces).sort{|a,b| b.updated_at <=> a.updated_at }.first(5)
    @latest_posts=[]
=begin
    if params[:hcard]
      hcard
      return
    end
=end    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @profile }
      format.vcf  { vcard }
    end
  end

=begin
  # GET /profile/new
  # GET /profile/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end
=end

  # GET /profiles/edit
  def edit
    if @profile.new_record?
      #flash[:notice]= 'You must create your profile first'
      #redirect_to new_user_profile_path(@user)
      @profile = @user.profile.create
    end
  end
  
=begin
  # POST /profile
  # POST /profile.xml
  def create
    
    @profile = @user.build_profile(params[:profile])

    if params[:vcard_file].present?
      
      upload_vcard
      
      render :action => 'new'
      return
    end

    respond_to do |format|
      if @profile.save
        flash[:success] = t('profile.created')
        format.html { redirect_to :action => 'show' }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end
  
=end

  # PUT /profile
  # PUT /profile.xml
  def update
    
    if params[:vcard_file].present?
      
      upload_vcard
      
      #redirect_to :action => 'edit'
      render :action => 'edit'
      return
    end
    
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = t('profile.updated')
        format.html { redirect_to :action => "show" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /profile
  # DELETE /profile.xml
  def destroy
    @profile.destroy
    flash[:notice] = t('profile.deleted')
    respond_to do |format|
      format.html { redirect_to(user_profile_path(@user)) }
      format.xml  { head :ok }
    end
  end
  
  
  private

  def get_user
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
    @profile = @user.profile || @user.build_profile
  end
  
  #this is used to create the hcard microformat of an user in order to show it in the application
  def hcard
    if @profile.nil?
      flash[:notice]= t('profile.must_create')
      redirect_to new_space_user_profile_path(@space, :user_id=>current_user.id)
    else
        render :partial=>'public_hcard'
      if @profile.authorize? :read, :to => current_user
        render :partial=>'private_hcard'
      end
    end
  end
  
  
  #this method is used to compose the vcard file (.vcf) with the profile of an user
  def vcard
    email = User.find(profile.user_id).email
    @card = Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.given = profile.name
        name.family = profile.lastname
        name.prefix = profile.prefix
      end
      maker.add_addr do |addr|
        addr.preferred = true
        addr.location = 'home'
        addr.street = profile.address
        addr.locality = profile.city
        addr.country = profile.country
        addr.postalcode = profile.zipcode
        addr.region = profile.province
      end
      maker.add_tel(profile.phone) do |tel|
        tel.location = 'work'
        tel.preferred = true
      end
      if profile.mobile == ""
        maker.add_tel('Not defined') do |tel|
          tel.location = 'cell'
        end
      else
        maker.add_tel(profile.mobile) do |tel|
          tel.location = 'cell'
        end  
      end
      if profile.fax == ""
        maker.add_tel('Not defined') do |tel|
          tel.location = 'work'
          tel.capability = 'fax'
        end
      else
        maker.add_tel(profile.fax) do |tel|
          tel.location = 'work'
          tel.capability = 'fax'
        end
      end
      maker.add_email(email) { |e| e.location = 'work' }
      maker.add_url(profile.url)
    end
    send_data @card.to_s, :filename => "vcard_#{profile.name}.vcf"
  end
  
  def unique_profile
    unless @user.profile.new_record?
      flash[:error] = t('profile.error.exist')     
      redirect_to user_profile_path(@user)
    end
 end
 
  def upload_vcard
    @vcard = params[:vcard_file][:data]
   begin
      @vcard = Vpim::Vcard.decode(@vcard).first
      
        #TELEFONO: Primero el preferente, sino, trabajo, sino, casa, 
        #y sino, cualquier otro numero
        if !@vcard.telephone('pref').nil? 
          @profile.phone = @vcard.telephone('pref')
        else 
          if !@vcard.telephone('work').nil?
            @profile.phone = @vcard.telephone('work')
          elsif !@vcard.telephone('home').nil?
            @profile.phone = @vcard.telephone('home')
          elsif !(@vcard.telephones.nil?||@vcard.telephones[0].nil?)
            @profile.phone = @vcard.telephones[0]
          end
        end
        
        #FAX: Si existe bien, sino no se altera
        if !@vcard.telephone('fax').nil?
          @profile.fax = @vcard.telephone('fax') 
        end
 
       #NOMBRE: Guardamos el prefijo si existe en su campo
       #y con el resto formamos el nombre de la forma
       # "given" + "additional" + "family"
       if !@vcard.name.nil?
         
          temporal = ''
          
          if !@vcard.name.prefix.eql? ''
            @profile.prefix = @vcard.name.prefix
          end  
          if !@vcard.name.given.eql? ''
            temporal =  @vcard.name.given + ' '
          end
          if !@vcard.name.additional.eql? ''
            temporal = temporal + @vcard.name.additional + ' ' 
          end             
          if !@vcard.name.family.eql? ''
            temporal = temporal + @vcard.name.family
          end
          
          if !temporal.eql? '' 
            @profile.user.login = temporal.unpack('M*')[0];
          end
       end
          
        #EMAIL: Primero el preferente, sino, trabajo, sino, casa, 
        #y sino, cualquier otro mail
        if !@vcard.email('pref').nil? 
          @profile.user.email = @vcard.email('pref')
        else 
          if !@vcard.email('work').nil?
            @profile.user.email = @vcard.email('work')
          elsif !@vcard.email('home').nil?
            @profile.user.email = @vcard.email('home')
          elsif !(@vcard.emails.nil?||@vcard.emails[0].nil?)
            @profile.user.email = @vcard.emails[0]
          end
        end
        
        #URL: Primero el preferente, sino, trabajo, sino, casa, 
        #y sino, cualquier otro mail
        if !@vcard.url.nil?
            @profile.url = @vcard.url.uri.to_s
        end

        #DESCRIPCIÓN: Si existe Note, se pone en descripción
        if !@vcard.note.nil?
            @profile.description = @vcard.note.unpack('M*')[0]
        end
      
        #ORGANIZACIÓN: Por ahora solo se tiene en cuenta
        #el nombre de la organización. Hay campos para 
        #departamentos ... ¿útiles?
        if !@vcard.org.nil?  
          @profile.organization = @vcard.org[0].unpack('M*')[0]
        end 
      
        #DIRECCIÓN: Buscamos preferente, sino trabajo, sino
        #cualquier otra dirección. Solo ejecutamos los cambios
        #si hay una address en la vcard
        address = nil;              
        if !@vcard.address('pref').nil? 
          address = @vcard.address('pref')
        else 
          if !@vcard.address('work').nil?
            address = @vcard.address('work')
          elsif !(@vcard.addresses.nil?||@vcard.addresses[0].nil?)
            address = @vcard.addresses[0]
          end
        end            
        if !address.nil? #Si ha habido algún resultado, lo guardamos
              @profile.address = address.street.unpack('M*')[0] + ' ' + address.extended.unpack('M*')[0]
              @profile.city = address.locality.unpack('M*')[0]
              @profile.zipcode = address.postalcode.unpack('M*')[0]
              @profile.province = address.region.unpack('M*')[0]
              @profile.country = address.country.unpack('M*')[0]
        end
      flash.now[:notice] = t("vCard.success")
    rescue
      flash.now[:error] = t("vCard.corrupt")
    end
  end
end

