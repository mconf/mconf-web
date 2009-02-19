require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReadersController do
  include ActionController::AuthenticationTestHelper
  fixtures :users , :spaces

  def mock_reader(stubs={})
    @mock_reader ||= mock_model(Reader, stubs)
  end
  
  before(:each) do
      @space = spaces(:public)
  end
  
  
  describe "responding to GET index" do


    it "should expose all readers as @readers" do
      Reader.should_receive(:find).with(:all, :conditions => {:space_id => @space.id}).and_return([mock_reader])
      get :index, :space_id => @space.name
      assigns[:readers].should == [mock_reader]
    end

    describe "with mime type of xml" do
  
      it "should render all readers as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Reader.should_receive(:find).with(:all, :conditions => {:space_id => @space.id}).and_return(readers = mock("Array of Readers"))
        readers.should_receive(:to_xml).and_return("generated XML")
        get :index, :space_id => @space.name
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested reader as @reader" do
      Reader.should_receive(:find).with("37", :conditions => {:space_id => @space.id}).and_return(mock_reader)
      get :show, :id => "37", :space_id => @space.name
      assigns[:reader].should equal(mock_reader)
    end
    
    describe "with mime type of xml" do

      it "should render the requested reader as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Reader.should_receive(:find).with("37", :conditions => {:space_id => @space.id}).and_return(mock_reader)
        mock_reader.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :space_id => @space.name
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new reader as @reader" do
      Reader.should_receive(:new).and_return(mock_reader)
      get :new, :space_id => @space.name
      assigns[:reader].should equal(mock_reader)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested reader as @reader" do
      Reader.should_receive(:find).with("37", :conditions => {:space_id => @space.id}).and_return(mock_reader)
      get :edit, :id => "37", :space_id => @space.name
      assigns[:reader].should equal(mock_reader)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created reader as @reader" do
        Reader.should_receive(:new).with({'these' => 'params'}).and_return(mock_reader(:save => true))
        post :create, :reader => {:these => 'params'}, :space_id => @space.name
        assigns(:reader).should equal(mock_reader)
      end

      it "should redirect to the created reader" do
        Reader.stub!(:new).and_return(mock_reader(:save => true))
        post :create, :reader => {}, :space_id => @space.name
        response.should redirect_to(space_reader_url(@space, mock_reader))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved reader as @reader" do
        Reader.stub!(:new).with({'these' => 'params'}).and_return(mock_reader(:save => false))
        post :create, :reader => {:these => 'params'}, :space_id => @space.name
        assigns(:reader).should equal(mock_reader)
      end

      it "should re-render the 'new' template" do
        Reader.stub!(:new).and_return(mock_reader(:save => false))
        post :create, :reader => {}, :space_id => @space.name
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested reader" do
        Reader.should_receive(:find).with("37").and_return(mock_reader)
        mock_reader.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :reader => {:these => 'params'}, :space_id => @space.name
      end

      it "should expose the requested reader as @reader" do
        Reader.stub!(:find).and_return(mock_reader(:update_attributes => true))
        put :update, :id => "1", :space_id => @space.name
        assigns(:reader).should equal(mock_reader)
      end

      it "should redirect to the reader" do
        Reader.stub!(:find).and_return(mock_reader(:update_attributes => true))
        put :update, :id => "1", :space_id => @space.name
        response.should redirect_to(space_reader_url(@space, mock_reader))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested reader" do
        Reader.should_receive(:find).with("37").and_return(mock_reader)
        mock_reader.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :reader => {:these => 'params'}, :space_id => @space.name
      end

      it "should expose the reader as @reader" do
        Reader.stub!(:find).and_return(mock_reader(:update_attributes => false))
        put :update, :id => "1", :space_id => @space.name
        assigns(:reader).should equal(mock_reader)
      end

      it "should re-render the 'edit' template" do
        Reader.stub!(:find).and_return(mock_reader(:update_attributes => false))
        put :update, :id => "1", :space_id => @space.name
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested reader" do
      Reader.should_receive(:find).with("37").and_return(mock_reader)
      mock_reader.should_receive(:destroy)
      delete :destroy, :id => "37", :space_id => @space.name
    end
  
    it "should redirect to the readers list" do
      Reader.stub!(:find).and_return(mock_reader(:destroy => true))
      delete :destroy, :id => "1", :space_id => @space.name
      response.should redirect_to(space_readers_url(@space))
    end

  end

end
