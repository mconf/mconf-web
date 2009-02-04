require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')



describe MachinesController do
  include ActionController::AuthenticationTestHelper
  fixtures :users
  
  
  
  def mock_machine(stubs={})
    @mock_machine ||= mock_model(Machine, stubs)
  end
  
  describe "when logged in" do
    
    describe "as admin" do
      
      before(:each) do
        login_as(:user_admin)
      end
      
      
      describe "responding to GET index" do
        
        it "should expose all machines as @machines" do
          Machine.should_receive(:find).with(:all).and_return([mock_machine])
          get :index
          assigns[:machines].should == [mock_machine]
        end
        
        describe "with mime type of xml" do
          
          it "should render all machines as xml" do
            request.env["HTTP_ACCEPT"] = "application/xml"
            Machine.should_receive(:find).with(:all).and_return(machines = mock("Array of Machines"))
            machines.should_receive(:to_xml).and_return("generated XML")
            get :index
            response.body.should == "generated XML"
          end
          
        end
        
      end
      
      describe "responding to GET show" do
        
        it "should expose the requested machine as @machine" do
          Machine.should_receive(:find).with("37").and_return(mock_machine)
          get :show, :id => "37"
          assigns[:machine].should equal(mock_machine)
        end
        
        describe "with mime type of xml" do
          
          it "should render the requested machine as xml" do
            request.env["HTTP_ACCEPT"] = "application/xml"
            Machine.should_receive(:find).with("37").and_return(mock_machine)
            mock_machine.should_receive(:to_xml).and_return("generated XML")
            get :show, :id => "37"
            response.body.should == "generated XML"
          end
          
        end
        
      end
      
      describe "responding to GET new" do
        
        it "should expose a new machine as @machine" do
          Machine.should_receive(:new).and_return(mock_machine)
          get :new
          assigns[:machine].should equal(mock_machine)
        end
        
      end
      
      describe "responding to GET edit" do
        
        it "should expose the requested machine as @machine" do
          Machine.should_receive(:find).with("37").and_return(mock_machine)
          get :edit, :id => "37"
          assigns[:machine].should equal(mock_machine)
        end
        
      end
      
      describe "responding to POST create" do
        
        describe "with valid params" do
          
          it "should expose a newly created machine as @machine" do
            Machine.should_receive(:new).with({'these' => 'params'}).and_return(mock_machine(:save => true))
            post :create, :machine => {:these => 'params'}
            assigns(:machine).should equal(mock_machine)
          end
          
          it "should redirect to the created machine" do
            Machine.stub!(:new).and_return(mock_machine(:save => true))
            post :create, :machine => {}
            response.should redirect_to(machines_url)
          end
          
        end
        
        describe "with invalid params" do
          
          it "should expose a newly created but unsaved machine as @machine" do
            Machine.stub!(:new).with({'these' => 'params'}).and_return(mock_machine(:save => false))
            post :create, :machine => {:these => 'params'}
            assigns(:machine).should equal(mock_machine)
          end
          
          it "should re-render the 'new' template" do
            Machine.stub!(:new).and_return(mock_machine(:save => false))
            post :create, :machine => {}
            response.should render_template('index')
          end
          
        end
        
      end
      
      describe "responding to PUT udpate" do
        
        describe "with valid params" do
          
          it "should update the requested machine" do
            Machine.should_receive(:find).with("37").and_return(mock_machine)
            mock_machine.should_receive(:update_attributes).with({'these' => 'params'}).and_return(true)
            put :update, :id => "37", :machine => {:these => 'params'}
          end
          
          it "should expose the requested machine as @machine" do
            Machine.stub!(:find).and_return(mock_machine(:update_attributes => true))
            put :update, :id => "1"
            assigns(:machine).should equal(mock_machine)
          end
          
          it "should redirect to the machine" do
            Machine.stub!(:find).and_return(mock_machine(:update_attributes => true))
            put :update, :id => "1"
            response.should redirect_to(machines_url)
          end
          
        end
        
        describe "with invalid params" do
          
          it "should update the requested machine" do
            
            Machine.should_receive(:find).with("37").and_return(mock_machine)
            mock_machine.should_receive(:update_attributes).with({'these' => 'params'}).and_return(false)
            Machine.should_receive(:find).with(:all).and_return([mock_machine])
            
            put :update, :id => "37", :machine => {:these => 'params'}
            
            response.should render_template("index")
          end
          
          it "should expose the machine as @machine" do
            Machine.stub!(:find).and_return(mock_machine(:update_attributes => false))
            put :update, :id => "1"
            assigns(:machine).should equal(mock_machine)
          end
          
          it "should re-render the 'index' template" do
            Machine.stub!(:find).and_return(mock_machine(:update_attributes => false))
            put :update, :id => "1"
            response.should render_template('index')
          end
          
        end
        
      end
      
      describe "responding to DELETE destroy" do
        
        it "should destroy the requested machine" do
          Machine.should_receive(:find).with("37").and_return(mock_machine)
          mock_machine.should_receive(:destroy)
          delete :destroy, :id => "37"
        end
        
        it "should redirect to the machines list" do
          Machine.stub!(:find).and_return(mock_machine(:destroy => true))
          delete :destroy, :id => "1"
          response.should redirect_to(machines_url)
        end
      end
    end
    
    
    describe "as normal user" do
      
      before(:each) do
        login_as(:user_alfredo)
        machine = mock(Machine, :id => '1')
      end
      
      def error_message
        "Action not allowed"
      end
      
      describe "responding to GET index" do
        
        it "should not be allowed" do
          get :index
          flash[:notice].should include(error_message)
          response.should redirect_to(root_path)
        end
      end
      
      describe "responding to GET show" do
        
        it "should not be allowed" do
          get :show, :id => '1'
          flash[:notice].should include(error_message)
          response.should redirect_to(root_path)
        end
        
      end
      
      describe "responding to GET new" do
        
        it "should not be allowed" do
          get :new
          flash[:notice].should include(error_message)
          response.should redirect_to(root_path)
        end
        
      end
      
      describe "responding to GET edit" do
        
        it "should not be allowed" do
          get :edit, :id => '1'
          flash[:notice].should include(error_message)
          response.should redirect_to(root_path)
        end
        
      end
      
      describe "responding to POST create" do
        
        it "should not be allowed" do
          post :create
          flash[:notice].should include(error_message)
          response.should redirect_to(root_path)
        end
        
      end
      
      describe "responding to PUT udpate" do
        
        it "should not be allowed" do
          put :update, :id => '1'
          flash[:notice].should include(error_message)
          response.should redirect_to(root_path)
        end
        
      end
      
      describe "responding to DELETE destroy" do
        
        it "should not be allowed" do
          delete :destroy, :id => '1'
          flash[:notice].should include(error_message)
          response.should redirect_to(root_path)
        end
      end
      
      
    end
  end
end
