require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do

  def mock_profile(stubs={})
    @mock_profile ||= mock_model(Profile, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all profiles as @profiles" do
      pending
      Profile.should_receive(:find).with(:all).and_return([mock_profile])
      get :index
      assigns[:profiles].should == [mock_profile]
    end

    describe "with mime type of xml" do
  
      it "should render all profiles as xml" do
        pending
        request.env["HTTP_ACCEPT"] = "application/xml"
        Profile.should_receive(:find).with(:all).and_return(profiles = mock("Array of Profiles"))
        profiles.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested profile as @profile" do
      pending
      Profile.should_receive(:find).with("37").and_return(mock_profile)
      get :show, :id => "37"
      assigns[:profile].should equal(mock_profile)
    end
    
    describe "with mime type of xml" do

      it "should render the requested profile as xml" do
        pending
        request.env["HTTP_ACCEPT"] = "application/xml"
        Profile.should_receive(:find).with("37").and_return(mock_profile)
        mock_profile.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new profile as @profile" do
      pending
      Profile.should_receive(:new).and_return(mock_profile)
      get :new
      assigns[:profile].should equal(mock_profile)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested profile as @profile" do
      pending
      Profile.should_receive(:find).with("37").and_return(mock_profile)
      get :edit, :id => "37"
      assigns[:profile].should equal(mock_profile)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created profile as @profile" do
        pending
        Profile.should_receive(:new).with({'these' => 'params'}).and_return(mock_profile(:save => true))
        post :create, :profile => {:these => 'params'}
        assigns(:profile).should equal(mock_profile)
      end

      it "should redirect to the created profile" do
        pending
        Profile.stub!(:new).and_return(mock_profile(:save => true))
        post :create, :profile => {}
        response.should redirect_to(profile_url(mock_profile))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved profile as @profile" do
        pending
        Profile.stub!(:new).with({'these' => 'params'}).and_return(mock_profile(:save => false))
        post :create, :profile => {:these => 'params'}
        assigns(:profile).should equal(mock_profile)
      end

      it "should re-render the 'new' template" do
        pending
        Profile.stub!(:new).and_return(mock_profile(:save => false))
        post :create, :profile => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested profile" do
        pending
        Profile.should_receive(:find).with("37").and_return(mock_profile)
        mock_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :profile => {:these => 'params'}
      end

      it "should expose the requested profile as @profile" do
        pending
        Profile.stub!(:find).and_return(mock_profile(:update_attributes => true))
        put :update, :id => "1"
        assigns(:profile).should equal(mock_profile)
      end

      it "should redirect to the profile" do
        pending
        Profile.stub!(:find).and_return(mock_profile(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(profile_url(mock_profile))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested profile" do
        pending
        Profile.should_receive(:find).with("37").and_return(mock_profile)
        mock_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :profile => {:these => 'params'}
      end

      it "should expose the profile as @profile" do
        pending
        Profile.stub!(:find).and_return(mock_profile(:update_attributes => false))
        put :update, :id => "1"
        assigns(:profile).should equal(mock_profile)
      end

      it "should re-render the 'edit' template" do
        pending
        Profile.stub!(:find).and_return(mock_profile(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested profile" do
      pending
      Profile.should_receive(:find).with("37").and_return(mock_profile)
      mock_profile.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the profiles list" do
      pending
      Profile.stub!(:find).and_return(mock_profile(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(profiles_url)
    end

  end

end
