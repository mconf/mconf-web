require 'vpim/vcard'

class ProfilesController < ApplicationController
  # GET /profiles
  # GET /profiles.xml
  before_filter :authentication_required
  def index
    @profile = Profile.find_by_users_id(current_user.id )
    if @profile == nil
        @profile = Profile.new
    end


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @profile = Profile.find_by_users_id(current_user.id )
   # debugger
    if @profile == nil
        @profile = Profile.new
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    @profile = Profile.find(params[:id])
  end


  # POST /profiles
  # POST /profiles.xml
  def create
    
    @profile = Profile.new(params[:profile])
    @profile.users_id = current_user.id
    respond_to do |format|
      if @profile.save
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to(:action => "index", :controller => "profiles") }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @profile = Profile.find(params[:id])

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = 'Profile was successfully updated.'
        format.html { render :action => "index" }
        format.xml  { head :ok }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(profiles_url) }
      format.xml  { head :ok }
    end
  end
  
  #this is used to create the hcard microformat of an user in order to show it in the application
  def hcard
  @profile = Profile.find_by_users_id(current_user.id )
  @user = User.find(@profile.users_id)
end
#this method is used to compose the vcard file (.vcf) with the profile of an user
def vcard
profile = Profile.find_by_users_id(current_user.id )
email = User.find(profile.users_id).email
@card = Vpim::Vcard::Maker.make2 do |maker|
  maker.add_name do |name|
    name.given = profile.name
    name.family = profile.lastname
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
       end
 send_data @card.to_s, :filename => "vcard_#{profile.name}.vcf"
end
#this method is used when a user want to import his vcard file.
def import_vcard
  
end


end
