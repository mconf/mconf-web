require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')



describe SpacesController do
  include CMS::AuthenticationTestHelper
  fixtures :users , :spaces
  
  
  
  def mock_space(stubs={})
    @mock_space ||= mock_model(space, stubs)
  end
  
  
  describe "responding to GET index" do
    
    describe "when you are logged in" do
      
      describe "as super Admin" do
        
        before(:each) do
          login_as(:user_admin)
        end
        
        it "should let users to see the space index" do
          get :index
          assigns[:spaces].should_not equal(nil) 
          assert_response 200
        end
        
      end
      
      describe "as normal User" do
        
        before(:each) do
          login_as(:user_normal)
        end
        
        it "should let users to see the space index" do
          get :index
          assigns[:spaces].should_not equal(nil) 
          assert_response 200
        end
        
      end
      
    end
    
    describe "when you are not logged in" do
      
      it "should let users to see the space index" do
        pending("Un usuario no loggeado podría ver el índice de espacios de la aplicación")do
        get :index
        assigns[:spaces].should equal(nil) 
        assert_response 200
      end
    end
    
  end
  
end

#####################


describe "responding to GET show" do
  
  describe " When you are logged in" do
    
    describe "as Super Admin" do
      
      before(:each) do
        login_as(:user_admin)
      end
      
      it "should let Super Admin to see a private space" do
        get :show, :id => spaces(:private_no_roles).name
        assert_response 200
      end
      
      it "should let Super Admin to see the public space" do
        get :show, :id => spaces(:public).name
        assert_response 200
      end
      
    end
    
    describe "as normal User" do
      
      before(:each)do
      login_as(:user_normal)
    end
    
    describe " in a private space where the user has the role Admin" do
      it "should let the user to see a private space" do
         pending("debería dejar al usuario ver un espacio en el cual tiene el rol de admin")do
        get :show, :id => spaces(:private_admin).name
        assert_response 200
        end
      end
    end
    
    describe " in a private space where the user has the role User" do
      it "should let the user to see a private space" do
        get :show, :id => spaces(:private_user).name
        assert_response 200
      end  
    end
    
    describe "in a private space where the user has the role Invited" do
      it "should let the user to see a private space" do
        get :show, :id => spaces(:private_invited).name
        assert_response 200
      end
    end
    
    describe "in a private space where the user has no roles" do
      it "should not let the user to see a private space" do
        get :show, :id => spaces(:private_no_roles).name
        assert_response 403
      end
    end
    
    describe "in the public space" do
      it "should let the user to see a private space" do
        get :show, :id => spaces(:public).name
        assert_response 200
      end
    end
  end
end  

describe "If you are not logged in" do
  it "should not let the user to see a private space" do
    get :show, :id => spaces(:private_no_roles).name
    assert_response 403
  end
  
  it "should let the user to see a public space" do
    get :show, :id => spaces(:public).name
    assert_response 200
  end
  
end

end

##########################

describe "responding to GET new" do

describe "when you are logged in" do
  describe " as Super Admin" do
    before(:each) do
      login_as(:user_admin)
    end
    
    it "should let the User to create a space and the user" do
      get :new 
      assert_response 200
      
    end
    
  end
  
  describe " as normal User" do
    before(:each)do
    login_as(:user_normal)
  end
      it "should let the User to create a space and the user and this User should be role admin of this space" do
        pending("concretamos que cualquier usuario registrado puede crear un espacio y debe convertirse en admin de ese espacio ")do
        get :new 
        assert_response 200
        end
      end  
  end
end

describe "if you are not logged in" do
    it "should not let to create a space" do
      pending("debería dar error 403 en vez de redirigir al home después de no dejar crear el espacio")do
      get :new 
      assert_response 403
      end
    end  
end




end


##########################
describe "responding to GET edit" do

it "should expose the requested space as @space" do
Space.should_receive(:find).with("37").and_return(mock_space)
get :edit, :id => "37"
assigns[:space].should equal(mock_space)
end

end

#################

describe "responding to POST create" do

describe "with valid params" do

it "should expose a newly created space as @space" do
  Space.should_receive(:new).with({'these' => 'params'}).and_return(mock_space(:save => true))
  post :create, :space => {:these => 'params'}
  assigns(:space).should equal(mock_space)
end

it "should redirect to the created space" do
  Space.stub!(:new).and_return(mock_space(:save => true))
  post :create, :space => {}
  response.should redirect_to(spaces_url)
end

end

describe "with invalid params" do

it "should expose a newly created but unsaved space as @space" do
  Space.stub!(:new).with({'these' => 'params'}).and_return(mock_space(:save => false))
  post :create, :space => {:these => 'params'}
  assigns(:space).should equal(mock_space)
end

it "should re-render the 'new' template" do
  Space.stub!(:new).and_return(mock_space(:save => false))
  post :create, :space => {}
  response.should render_template('index')
end

end

end


####################

describe "responding to PUT udpate" do

describe "with valid params" do

it "should update the requested space" do
  Space.should_receive(:find).with("37").and_return(mock_space)
  mock_space.should_receive(:update_attributes).with({'these' => 'params'}).and_return(true)
  put :update, :id => "37", :space => {:these => 'params'}
end

it "should expose the requested space as @space" do
  Space.stub!(:find).and_return(mock_space(:update_attributes => true))
  put :update, :id => "1"
  assigns(:space).should equal(mock_space)
end

it "should redirect to the space" do
  Space.stub!(:find).and_return(mock_space(:update_attributes => true))
  put :update, :id => "1"
  response.should redirect_to(spaces_url)
end

end

describe "with invalid params" do

it "should update the requested space" do
  
  Space.should_receive(:find).with("37").and_return(mock_space)
  mock_space.should_receive(:update_attributes).with({'these' => 'params'}).and_return(false)
  Space.should_receive(:find).with(:all).and_return([mock_space])
  
  put :update, :id => "37", :space => {:these => 'params'}
  
  response.should render_template("index")
end

it "should expose the space as @space" do
  Space.stub!(:find).and_return(mock_space(:update_attributes => false))
  put :update, :id => "1"
  assigns(:space).should equal(mock_space)
end

it "should re-render the 'index' template" do
  Space.stub!(:find).and_return(mock_space(:update_attributes => false))
  put :update, :id => "1"
  response.should render_template('index')
end

end

end

##################################

describe "responding to DELETE destroy" do

it "should destroy the requested space" do
Space.should_receive(:find).with("37").and_return(mock_space)
mock_space.should_receive(:destroy)
delete :destroy, :id => "37"
end

it "should redirect to the spaces list" do
Space.stub!(:find).and_return(mock_space(:destroy => true))
delete :destroy, :id => "1"
response.should redirect_to(spaces_url)
end
end   
end
