require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
=begin
describe GroupsController do

  def mock_group(stubs={})
    @mock_group ||= mock_model(Group, stubs)
    @space = mock(Space, :id => '1', :name => "espacio")
  end
  
  describe "responding to GET index" do

    it "should expose all groups as @groups" do
      Group.should_receive(:find).with(:all).and_return([mock_group])
      get :index, :space_id => @space.name
      assigns[:groups].should == [mock_group]
    end

    describe "with mime type of xml" do
  
      it "should render all groups as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Group.should_receive(:find).with(:all).and_return(groups = mock("Array of Groups"))
        groups.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested group as @group" do
      Group.should_receive(:find).with("37").and_return(mock_group)
      get :show, :id => "37"
      assigns[:group].should equal(mock_group)
    end
    
    describe "with mime type of xml" do

      it "should render the requested group as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Group.should_receive(:find).with("37").and_return(mock_group)
        mock_group.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new group as @group" do
      Group.should_receive(:new).and_return(mock_group)
      get :new
      assigns[:group].should equal(mock_group)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested group as @group" do
      Group.should_receive(:find).with("37").and_return(mock_group)
      get :edit, :id => "37"
      assigns[:group].should equal(mock_group)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created group as @group" do
        Group.should_receive(:new).with({'these' => 'params'}).and_return(mock_group(:save => true))
        post :create, :group => {:these => 'params'}
        assigns(:group).should equal(mock_group)
      end

      it "should redirect to the created group" do
        Group.stub!(:new).and_return(mock_group(:save => true))
        post :create, :group => {}
        response.should redirect_to(group_url(mock_group))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved group as @group" do
        Group.stub!(:new).with({'these' => 'params'}).and_return(mock_group(:save => false))
        post :create, :group => {:these => 'params'}
        assigns(:group).should equal(mock_group)
      end

      it "should re-render the 'new' template" do
        Group.stub!(:new).and_return(mock_group(:save => false))
        post :create, :group => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested group" do
        Group.should_receive(:find).with("37").and_return(mock_group)
        mock_group.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :group => {:these => 'params'}
      end

      it "should expose the requested group as @group" do
        Group.stub!(:find).and_return(mock_group(:update_attributes => true))
        put :update, :id => "1"
        assigns(:group).should equal(mock_group)
      end

      it "should redirect to the group" do
        Group.stub!(:find).and_return(mock_group(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(group_url(mock_group))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested group" do
        Group.should_receive(:find).with("37").and_return(mock_group)
        mock_group.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :group => {:these => 'params'}
      end

      it "should expose the group as @group" do
        Group.stub!(:find).and_return(mock_group(:update_attributes => false))
        put :update, :id => "1"
        assigns(:group).should equal(mock_group)
      end

      it "should re-render the 'edit' template" do
        Group.stub!(:find).and_return(mock_group(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested group" do
      Group.should_receive(:find).with("37").and_return(mock_group)
      mock_group.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the groups list" do
      Group.stub!(:find).and_return(mock_group(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(groups_url)
    end

  end

end
=end