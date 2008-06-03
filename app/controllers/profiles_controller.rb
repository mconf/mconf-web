require 'vpim/vcard'

class ProfilesController < ApplicationController
  include CMS::Controller::Base

  before_filter :authentication_required
  before_filter :profile_owner, :only=>[:new,:create,:show, :edit, :update, :destroy,  :vcard, :hcard]

  before_filter :unique_profile, :only=>[:new, :create]
  before_filter :get_space

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
   session[:current_tab] = "MyProfile" 
   
   @user = User.find_by_id(params[:user_id])
    @profile = @user.profile
    @user_spaces = @user.stages

    
    if @profile == nil
      flash[:notice]= 'You must create your profile first'
      redirect_to new_profile_path(:container_id=>@space.id, :container_type=>:space, :user_id=>current_user.id)
    else
   # debugger
   
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @profile }
    end
    end
  end

  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    session[:current_tab] = "MyProfile" 
    @user = User.find_by_id(params[:user_id])
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    session[:current_tab] = "MyProfile" 
    @user = User.find_by_id(params[:user_id])
    @profile = @user.profile
  end


  # POST /profiles
  # POST /profiles.xml
  def create
   
    @profile = Profile.new(params[:profile])
    @profile.user_id = current_user.id
    respond_to do |format|
      if @profile.save
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to(:action => "show", :controller => "profiles") }
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
   @user = User.find_by_id(params[:user_id])
    @profile = @user.profile

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = 'Profile was successfully updated.'
        format.html { render :action => "show" }
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
   @user = User.find_by_id(params[:user_id])
    @profile = @user.profile
    @profile.destroy
      flash[:notice] = 'Profile was successfully deleted.'
    respond_to do |format|
      format.html { redirect_to(space_user_profile_url(:space_id=>@space.id, :user_id=>@user.id)) }
      format.xml  { head :ok }
    end
  end
  
  #this is used to create the hcard microformat of an user in order to show it in the application
  def hcard
    
  @user = User.find_by_id(params[:user_id])
    @profile = @user.profile
    if @profile == nil
      flash[:notice]= 'You must create your profile first'
      redirect_to new_profile_path(:container_id=>@space.id, :container_type=>:space, :user_id=>current_user.id)
    else
  render :partial=>'hcard'
  end
end
#this method is used to compose the vcard file (.vcf) with the profile of an user
def vcard
 
@user = User.find_by_id(params[:user_id])
    profile = @user.profile
email = User.find(profile.user_id).email
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

private 



end
