require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do
  include ActionController::AuthenticationTestHelper
  
  integrate_views
  
 
  
  describe "when you are logged as" do
    
    ############################################# Super User  ############################################# 
    describe "super admin user" do 
      
      before(:each) do
        @current_user = Factory(:superuser)
        login_as(@current_user)
      end
      
      describe "and you are in a public space" do
        before(:each) do
          @current_space = Factory(:public_space)
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/new_thread_big.html.erb")
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
      end 
      
      
      describe "and you are in a private space" do
        before(:each) do
          @current_space = Factory(:private_space)
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/new_thread_big.html.erb")
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
      end
      describe "and you are in your space" do
        before(:each) do
          @current_space = Factory(:admin_performance, :agent => @current_user).stage
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/new_thread_big.html.erb")
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "title empty post." do
            post :create, :space_id => @current_space.to_param, :post => {"title"=> "", "text"=>  "Test"}
            assert_response 200
            flash[:error].should have_text(/#{ I18n.t('activerecord.errors.messages.blank') }/)
            response.should render_template("posts/index.html.erb")
          end       
          it "text empty post." do
            post :create, :space_id => @current_space.to_param, :post => {"title" => "Test", "text" => ""}
            pending "confirm blank text in posts"
            assert_response 200
            flash[:error].should == I18n.t('post.error.empty')
            response.should render_template("posts/index.html.erb")
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
      end
      describe "and you are in a space that you belong" do
        before(:each) do
          @performance = Factory(:admin_performance)
          
          @admin = @performance.agent
          @current_space = @performance.stage
          
          Factory(:user_performance, :stage => @current_space, :agent => @current_user)
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/new_thread_big.html.erb")
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
      end
      
      
      describe "and you are invited in one space" do
        before(:each) do
          @performance = Factory(:admin_performance)
          
          @admin = @performance.agent
          @current_space = @performance.stage
          
          Factory(:invited_performance, :stage => @current_space, :agent => @current_user)
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/new_thread_big.html.erb")
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
      end
    end
    ############################################# Super User  ############################################# 
    
    ############################################# Space Admin User  ############################################# 
    describe "space admin user" do 
      
      before(:each) do
        @performace_universe = Factory(:admin_performance)
        @space_universe = @performace_universe.stage
        @current_user = @performace_universe.agent
        login_as(@current_user)
      end
      
      describe "and you are in a public space" do
        before(:each) do
          @current_space = Factory(:public_space)
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 403
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 403
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
      end 
      
      
      
      
      describe "and you are in a private space" do
        before(:each) do
          @current_space = Factory(:private_space)
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 403
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 403
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 403
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
      end
      
      describe "and you are in your space" do
        before(:each) do
          #            @current_space = Factory(:admin_performance, :agent => @current_user).stage
          @current_space = @space_universe
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/new_thread_big.html.erb")
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "title empty post." do
            post :create, :space_id => @current_space.to_param, :post => {"title"=> "", "text"=>  "Test"}
            assert_response 200
            flash[:error].should have_text(/#{ I18n.t('activerecord.errors.messages.blank') }/)
            response.should render_template("posts/index.html.erb")
          end       
          it "text empty post." do
            post :create, :space_id => @current_space.to_param, :post => {"title" => "Test", "text" => ""}
            pending "confirm blank text in posts"
            assert_response 200
            flash[:error].should == I18n.t('post.error.empty')
            response.should render_template("posts/index.html.erb")
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
      end   
      
    end
    
    ############################################# Space Admin User  ############################################# 
    
    ############################################# Logged User  ############################################# 
    describe "logged user" do 
      
      before(:each) do
        @performace_universe = Factory(:user_performance)
        @space_universe = @performace_universe.stage
        @current_user = @performace_universe.agent
        login_as(@current_user)
      end
      
      describe "and you are in a public space" do
        before(:each) do
          @current_space = Factory(:public_space)
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 403
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 403
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
      end 
      
      
      
      
      describe "and you are in a private space" do
        before(:each) do
          @current_space = Factory(:private_space)
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 403
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 403
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 403
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
      end
      
      
      describe "and you are in a space that you belong" do
        before(:each) do
          @current_space = @space_universe
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/new_thread_big.html.erb")
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/edit_thread_big.html.erb")
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 302
            response.should redirect_to(space_posts_path)
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
      end
      
      
      describe "and you are invited in one space" do
        before(:each) do
          
          @current_space = Factory(:invited_performance, :agent => @current_user).stage
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          @post_mine = Factory(:post, :author => @current_user, :space => @current_space)
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          
          it "my post." do
            get :show, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 403
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 403
          end       
        end
        describe "trying to edit" do
          it "my post." do
            get :edit, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
        describe "trying to delete" do
          it "my post." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_mine.to_param
            assert_response 403
          end       
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 403
          end       
        end
      end
    end
    
    ############################################# Logged User  ############################################# 
    
    ############################################# No Logged User  ############################################# 
    describe "no logged user" do 
      
      before(:each) do
        #        @performace_universe = Factory(:admin_performance)
        #        @space_universe = @performace_universe.stage
        #        @current_user = Fac
        #        login_as(@current_user)
        @current_user= Factory(:user)
      end
      
      describe "and you are in a public space" do
        before(:each) do
          @current_space = Factory(:public_space)
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 200
            response.should render_template("posts/index.html.erb")
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 200
            response.should render_template("posts/show.html.erb")
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 401
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 401
          end       
        end
        describe "trying to edit" do
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 401
          end       
        end
        describe "trying to delete" do
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 401
          end       
        end
      end 
      
      
      
      describe "and you are in a private space" do
        before(:each) do
          @current_space = Factory(:private_space)
          
          @user = Factory(:user_performance, :stage => @current_space).agent
          
          
          @post_not_mine = Factory(:post, :author => @user, :space => @current_space)
        end
        
        describe "trying to see" do
          it "everybody post." do
            get :index, :space_id => @current_space.to_param
            assert_response 401
          end
          it "a post that isn't mine." do
            get :show, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 401
          end
        end
        
        describe "trying to acces to new" do
          it "page." do
            get :new, :space_id => @current_space.to_param
            assert_response 401
          end       
        end
        describe "trying to create a new" do
          it "post." do
            valid_attributes = Factory.attributes_for(:post)
            post :create, :space_id => @current_space.to_param, :post => valid_attributes
            assert_response 401
          end       
        end
        describe "trying to edit" do
          it "a post that isn't mine." do
            get :edit, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 401
          end       
        end
        describe "trying to delete" do
          it "a post that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @post_not_mine.to_param
            assert_response 401
          end       
        end
      end
    end
    
    ############################################# No Logged User  ############################################# 
    
    
  end
end




#  fixtures :users ,:spaces , :posts ,:entries , :attachments, :performances, :roles, :permissions
#  
#  def mock_post(stubs={})
#    @mock_post ||= mock_model(Post, stubs)
#  end
#  def mock_post(stubs={})
#    @mock_post ||= mock_model(Entry, stubs)
#  end
#  def mock_entry(stubs={})
#    @mock_entry ||= mock_model(Entry, stubs)
#  end  
#  
#  
#  def get_posts
#    @fixture_posts = []
#    for i in 1..30
#      @fixture_posts << posts(:"post_#{i}")
#    end
#    return @fixture_posts
#  end  
#
#        describe "in a private space" do
#          
#          before(:each) do
#            @space = spaces(:private_no_roles)
#            get_posts
#          end
#          
#          it "should have correct strings in session" do
#            get :index , :space_id => @space.name
#            session[:current_tab].should eql("News")
#            session[:current_sub_tab].should eql("")
#            
#          end
#          
#          it "should have a title in @title" do
#            get :index , :space_id => @space.name
#            assigns[:title].should include(@space.name)
#          end
#          
#          it "should expose all space posts as @posts" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post]) 
#            get :index , :space_id => @space.name
#            assigns[:posts].should == [mock_post]
#          end
#          
#          it "should expose the expand view if params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name , :expanded =>"true"
#            response.should render_template('index2')
#          end
#          
#          it "should not expose the expand view if not params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name 
#            response.should render_template('index')
#          end
#          
#          it "should paginate the posts using the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name, :per_page => 5
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 5).total_pages
#            assigns[:posts].total_pages.should_not == @fixture_posts.paginate(:page => params[:page], :per_page => 3).total_pages
#          end
#          
#          it "should paginate 10 :per_page without the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 10).total_pages
#          end
#        end
#        
#        describe "in the public space" do
#          before(:each) do
#            @space = spaces(:public)
#            get_posts
#          end
#          
#          it "should have correct strings in session" do
#            get :index , :space_id => @space.name
#            session[:current_tab].should eql("News")
#            session[:current_sub_tab].should eql("")
#          end
#          
#          it "should have a title in @title" do
#            get :index , :space_id => @space.name
#            assigns[:title].should include(@space.name)
#          end
#          
#          it "should expose all public posts as @posts" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name
#            assigns[:posts].should == [mock_post]
#          end
#          
#          it "should expose the expand view if params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name , :expanded =>"true"
#            response.should render_template('index2')
#          end
#          
#          it "should not expose the expand view if not params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name 
#            response.should render_template('index')
#          end
#          
#          it "should paginate the posts using the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name, :per_page => 5
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 5).total_pages
#            assigns[:posts].total_pages.should_not == @fixture_posts.paginate(:page => params[:page], :per_page => 3).total_pages
#          end
#          
#          it "should paginate 10 :per_page without the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 10).total_pages
#          end
#        end

#      end
#    end
#      
#      describe "normal user" do
#        
#        before(:each) do
#          login_as(:user_normal)
#        end
#               
#        describe "in a private space where user has the role Admin" do
#          
#          before(:each) do
#            @space = spaces(:private_admin)
#            get_posts
#          end
#          
#          it "should have correct strings in session" do
#            get :index , :space_id => @space.name
#            session[:current_tab].should eql("News")
#            session[:current_sub_tab].should eql("")
#          end
#          
#          it "should have a title in @title" do
#            get :index , :space_id => @space.name
#            assigns[:title].should include(@space.name)
#          end
#          
#          it "should expose all space posts as @posts" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name
#            assigns[:posts].should == [mock_post]
#          end
#          
#          it "should expose the expand view if params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name , :expanded =>"true"
#            response.should render_template('index2')
#          end
#          
#          it "should not expose the expand view if not params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name 
#            response.should render_template('index')
#          end
#          
#          it "should paginate the posts using the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name, :per_page => 5
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 5).total_pages
#            assigns[:posts].total_pages.should_not == @fixture_posts.paginate(:page => params[:page], :per_page => 3).total_pages
#          end
#          
#          it "should paginate 10 :per_page without the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 10).total_pages
#          end
#        end
#        
#        describe "in a private space where user has the role User" do
#          
#          before(:each) do
#            @space = spaces(:private_user)
#            get_posts
#          end
#          
#          it "should have correct strings in session" do
#            get :index , :space_id => @space.name
#            session[:current_tab].should eql("News")
#            session[:current_sub_tab].should eql("")
#          end
#          
#          it "should have a title in @title" do
#            get :index , :space_id => @space.name
#            assigns[:title].should include(@space.name)
#          end
#          
#          it "should expose all space posts as @posts" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name
#            assigns[:posts].should == [mock_post]
#          end
#          
#          it "should expose the expand view if params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name , :expanded =>"true"
#            response.should render_template('index2')
#          end
#          
#          it "should not expose the expand view if not params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name 
#            response.should render_template('index')
#          end
#          
#          it "should paginate the posts using the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name, :per_page => 5
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 5).total_pages
#            assigns[:posts].total_pages.should_not == @fixture_posts.paginate(:page => params[:page], :per_page => 3).total_pages
#          end
#          
#          it "should paginate 10 :per_page without the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 10).total_pages
#          end
#        end
#        
#        describe "in a private space where user has the role Invited" do
#          
#          before(:each) do
#            @space = spaces(:private_invited)
#            get_posts
#          end
#          
#          it "should have correct strings in session" do
#            get :index , :space_id => @space.name
#            session[:current_tab].should eql("News")
#            session[:current_sub_tab].should eql("")
#          end
#          
#          it "should have a title in @title" do
#            get :index , :space_id => @space.name
#            assigns[:title].should include(@space.name)
#          end
#          
#          it "should expose all space posts as @posts" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name
#            assigns[:posts].should == [mock_post]
#          end
#          
#          it "should expose the expand view if params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name , :expanded =>"true"
#            response.should render_template('index2')
#          end
#          
#          it "should not expose the expand view if not params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name 
#            response.should render_template('index')
#          end
#          
#          it "should paginate the posts using the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name, :per_page => 5
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 5).total_pages
#            assigns[:posts].total_pages.should_not == @fixture_posts.paginate(:page => params[:page], :per_page => 3).total_pages
#          end
#          
#          it "should paginate 10 :per_page without the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 10).total_pages
#          end
#        end
#        
#        describe "in a private space where user no has roles" do
#          
#          before(:each) do
#            @space = spaces(:private_no_roles)
#            get_posts
#          end
#          
#          it "should not let user to see the space index with expand" do
#            get :index , :space_id => @space.name, :expanded =>"true" 
#            assert_response 403
#          end
#          
#          it "should not let user to see the space index with normal view" do
#            get :index , :space_id => @space.name 
#            assert_response 403
#          end
#          
#          it "should not have @title, sessions, @posts, " do
#            get :index , :space_id => @space.name
#            assigns[:title].should eql(nil)
#            assigns[:posts].should eql(nil)
#            session[:current_tab].should eql(nil)
#            session[:current_sub_tab].should eql(nil)
#          end
#        end
#        
#        describe "in the public space" do
#          
#          before(:each) do
#            @space = spaces(:public)
#            get_posts
#          end
#          
#          it "should have correct strings in session" do
#            get :index , :space_id => @space.name
#            session[:current_tab].should eql("News")
#            session[:current_sub_tab].should eql("")
#          end
#          
#          it "should have a title in @title" do
#            get :index , :space_id => @space.name
#            assigns[:title].should include(@space.name)
#          end
#          
#          it "should expose all public posts as @posts" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name
#            assigns[:posts].should == [mock_post]
#          end
#          
#          it "should expose the expand view if params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name , :expanded =>"true"
#            response.should render_template('index2')
#          end
#          
#          it "should not expose the expand view if not params" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#            get :index , :space_id => @space.name 
#            response.should render_template('index')
#          end
#          
#          it "should paginate the posts using the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name, :per_page => 5
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 5).total_pages
#            assigns[:posts].total_pages.should_not == @fixture_posts.paginate(:page => params[:page], :per_page => 3).total_pages
#          end
#          
#          it "should paginate 10 :per_page without the param :per_page" do
#            Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_posts)
#            get :index , :space_id => @space.name
#            assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 10).total_pages
#          end
#        end
#      end
#    end
#    
#    describe "If you are not logged in" do
#      
#      describe "in a private space" do
#        
#        before(:each) do
#          @space = spaces(:private_no_roles)
#          get_posts
#        end
#        
#        it "should not let user to see the space index with expand view" do
#          get :index , :space_id => @space.name, :expanded =>"true" 
#          assert_response 403
#        end
#        
#        it "should not let user to see the space index with normal view" do
#          get :index , :space_id => @space.name 
#          assert_response 403
#        end
#        
#        it "should not have @title, sessions, @posts, " do
#          get :index , :space_id => @space.name
#          assigns[:title].should eql(nil)
#          assigns[:posts].should eql(nil)
#          session[:current_tab].should eql(nil)
#          session[:current_sub_tab].should eql(nil)
#        end
#      end
#      
#      describe "in the public space" do
#        
#        before(:each) do
#          @space = spaces(:public)
#          get_posts
#        end
#        
#        it "should have correct strings in session" do
#          get :index , :space_id => @space.name
#          session[:current_tab].should eql("News")
#          session[:current_sub_tab].should eql("")
#        end
#        
#        it "should have a title in @title" do
#          get :index , :space_id => @space.name
#          assigns[:title].should include(@space.name)
#        end
#        
#        it "should expose all public posts as @posts" do
#          Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#          get :index , :space_id => @space.name
#          assigns[:posts].should == [mock_post]
#        end
#        
#        it "should expose the expand view if params" do
#          Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#          get :index , :space_id => @space.name , :expanded =>"true"
#          response.should render_template('index2')
#        end
#        
#        it "should not expose the expand view if not params" do
#          Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_post])
#          get :index , :space_id => @space.name 
#          response.should render_template('index')
#        end
#        
#        it "should paginate the posts using the param :per_page" do
#          Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_posts)
#          get :index , :space_id => @space.name, :per_page => 5
#          assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 5).total_pages
#          assigns[:posts].total_pages.should_not == @fixture_posts.paginate(:page => params[:page], :per_page => 3).total_pages
#        end
#        
#        it "should paginate 10 :per_page without the param :per_page" do
#          Post.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_posts)
#          get :index , :space_id => @space.name
#          assigns[:posts].total_pages.should == @fixture_posts.paginate(:page => params[:page], :per_page => 10).total_pages
#        end
#      end  
#    end
#  end 
#  
#  
#  
#  ###################################
#  
#  describe "responding to GET show" do
#    # Para realizar estos tests, después de intentar realizarlos a base de emplear mocks, se ha comprobado que resulta muy complicado
#    # simular el comportamiento. Por ello se ha optado por usar fixtures. Para ello se han creado 4 objetos entries. Uno de ellos es el
#    # entry padre que tiene asociado un artículo (parent_post). Además hay 2 entries que tienen asociado 2 artículos y un entry que 
#    # tiene asociado un attachment. Estos 3 últimos entries tendrán un parent_id apuntando al entry padre para indicar que están relacionados  
#    #           
#    describe "when you are logged as" do
#    
#      describe "superadmin" do
#      
#        before(:each)do
#          login_as(:user_admin)
#        end
#      
#        describe "in a private space" do
#        
#          before(:each) do
#            @space = spaces(:private_no_roles)
#            @parent_post = posts(:parent_private_no_roles_post)
#            @children1_post = posts(:children_private_no_roles_post1)          
#          end
#        
#          it "should expose the requested post as @post" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:post].should == (@parent_post)
#          end
#        
#          it " should have the post title in @title" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:title].should == @parent_post.title
#          end
#        
#          it "should return the entries with attachment in @attachment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == [entries(:entry_private_no_roles_attachment_children3)]
#          end
#        
#          it "should return the post children in @comment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 4 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].size == 2
#            assigns[:comment_children].should include(entries(:entry_private_no_roles_children1),entries(:entry_private_no_roles_children2))
#          end
#        
#          it "should return [] if no attachments children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == []
#          end
#        
#          it "should return [] if no posts children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].should == []
#          end
#        end     
#    
#        describe "in the public space" do
#          
#          before(:each) do
#            @space = spaces(:public)
#            @parent_post = posts(:public_post)
#            @children1_post = posts(:public_children_post1)
#          end
#        
#          it "should expose the requested post as @post" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:post].should == (@parent_post)
#          end
#        
#          it " should have the post title in @title" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:title].should == @parent_post.title
#          end
#        
#          it "should return the entries with attachment in @attachment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == [entries(:entry_public_attachment_children3)]
#          end
#        
#          it "should return the post children in @comment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 4 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].size == 2
#            assigns[:comment_children].should include(entries(:entry_public_children1),entries(:entry_public_children2))
#          end
#        
#          it "should return [] if no attachments children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == []
#          end
#        
#          it "should return [] if no posts children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].should == []
#          end
#        end
#      end  
#    
#      describe "normal user"do
#        before(:each)do
#          login_as(:user_normal)
#        end
#  
#        describe "in a private space where the user has the role Admin" do
#          before(:each) do
#            @space = spaces(:private_admin)
#            @parent_post = posts(:parent_private_admin_post)
#            @children1_post = posts(:children_private_admin_post1)
#          end
#    
#          it "should expose the requested post as @post" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:post].should == (@parent_post)
#          end
#    
#          it " should have the post title in @title" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:title].should == @parent_post.title
#          end
#    
#          it "should return the entries with attachment in @attachment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == [entries(:entry_private_admin_attachment_children3)]
#          end
#    
#          it "should return the post children in @comment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 4 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].size == 2
#            assigns[:comment_children].should include(entries(:entry_private_admin_children1),entries(:entry_private_admin_children2))
#          end
#    
#          it "should return [] if no attachments children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == []
#          end
#    
#          it "should return [] if no posts children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].should == []
#          end
#        end
#  
#        describe "in a private space where the user has the role User" do
#          before(:each) do
#            @space = spaces(:private_user)
#            @parent_post = posts(:parent_private_user_post)
#            @children1_post = posts(:children_private_user_post1)
#          end
#    
#          it "should expose the requested post as @post" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:post].should == (@parent_post)
#          end
#    
#          it " should have the post title in @title" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:title].should == @parent_post.title
#          end
#    
#          it "should return the entries with attachment in @attachment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == [entries(:entry_private_user_attachment_children3)]
#          end
#    
#          it "should return the post children in @comment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 4 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].size == 2
#            assigns[:comment_children].should include(entries(:entry_private_user_children1),entries(:entry_private_user_children2))
#          end
#    
#          it "should return [] if no attachments children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == []
#          end
#    
#          it "should return [] if no posts children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].should == []
#          end
#        end
#  
#        describe "in a private space where the user has the role Invited" do
#          before(:each) do
#            @space = spaces(:private_invited)
#            @parent_post = posts(:parent_private_invited_post)
#            @children1_post = posts(:children_private_invited_post1)
#          end
#    
#          it "should expose the requested post as @post" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:post].should == (@parent_post)
#          end
#    
#          it " should have the post title in @title" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:title].should == @parent_post.title
#          end
#        
#          it "should return the entries with attachment in @attachment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == [entries(:entry_private_invited_attachment_children3)]
#          end
#    
#          it "should return the post children in @comment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 4 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].size == 2
#            assigns[:comment_children].should include(entries(:entry_private_invited_children1),entries(:entry_private_invited_children2))
#          end
#    
#          it "should return [] if no attachments children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == []
#          end
#    
#          it "should return [] if no posts children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].should == []
#          end
#        end 
#  
#        describe "in a private space where user have not roles on it" do
#          before(:each) do
#            @space = spaces(:private_no_roles)
#            @parent_post = posts(:parent_private_no_roles_post)
#            @children1_post = posts(:children_private_no_roles_post1)
#          end         
#    
#          #en estos  casos debería saltar el filtro directamente en vez de andar haciendo búsquedas que dicen que no hay usuario
#          it "should not let the user to see the post with an inexistent post" do 
#            assert_raise ActiveRecord::RecordNotFound do
#              get :show, :id => "254" , :space_id => @space.name
#            end
#          end
#    
#          it "should not let the user to see an post belonging to this space" do   
#            get :show, :id => posts(:parent_private_no_roles_post).id , :space_id => @space.name
#            assert_response 403
#          end
#        end
#  
#        describe "in the public space" do
#    
#          before(:each) do
#            @space = spaces(:public)
#            @parent_post = posts(:public_post)
#            @children1_post = posts(:public_children_post1)
#          end
#    
#          it "should expose the requested post as @post" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:post].should == (@parent_post)
#          end
#    
#          it " should have the post title in @title" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:title].should == @parent_post.title
#          end
#    
#          it "should return the entries with attachment in @attachment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == [entries(:entry_public_attachment_children3)]
#          end
#    
#          it "should return the post children in @comment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 4 childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].size == 2
#            assigns[:comment_children].should include(entries(:entry_public_children1),entries(:entry_public_children2))
#          end
#    
#          it "should return [] if no attachments children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == []
#          end
#    
#          it "should return [] if no posts children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :show, :id => "37" , :space_id => @space.name
#            assigns[:comment_children].should == []
#          end
#        end
#      end
#    end 
#    
#    describe "if you are not logged in " do
#
#      describe "a private space" do
#        before(:each) do
#          @space = spaces(:private_no_roles)      
#        end
#  
#        #en estos  casos debería saltar el filtro directamente en vez de andar haciendo búsquedas que dicen que no hay usuario
#        it "should not let the user to see the post with an inexistent post" do 
#          assert_raise ActiveRecord::RecordNotFound do
#            get :show, :id => "254" , :space_id => @space.name
#          end
#        end
#  
#        it "should not let the user to see an post belonging to this space" do   
#          get :show, :id => posts(:parent_private_no_roles_post).id , :space_id => @space.name
#          assert_response 403
#        end
#      end
#
#      describe "in the public space" do  
#        
#        before(:each) do
#          @space = spaces(:public)
#          @public_post = posts(:public_post)
#          @public_children_post1 = posts(:public_children_post1)
#          get_posts
#        end
#  
#        it "should expose the requested post as @post" do
#          Post.stub!(:find).and_return(@public_post)
#          get :show, :id => "37" , :space_id => @space.name
#          assigns[:post].should == (@public_post)
#        end
#  
#        it " should have the post title in @title" do
#          Post.stub!(:find).and_return(@public_post)
#          get :show, :id =>"37" , :space_id => @space.name
#          assigns[:title].should == @public_post.title
#        end
#  
#        it "should return the entries with attachment in @attachment_children" do
#          Post.stub!(:find).and_return(@public_post) # give the parent post, which have 3 childrens
#          get :show, :id => "37" , :space_id => @space.name
#          assigns[:attachment_children].should == [entries(:entry_public_attachment_children3)]
#        end
#  
#        it "should return the post children in @comment_children" do
#          Post.stub!(:find).and_return(@public_post) # give the parent post, which have 4 childrens
#          get :show, :id => "37" , :space_id => @space.name
#          assigns[:comment_children].size == 2
#          assigns[:comment_children].should include(entries(:entry_public_children1),entries(:entry_public_children2))
#        end
#  
#        it "should return [] if no attachments children" do
#          Post.stub!(:find).and_return(@public_children_post1) #give a children_post , which have not any childrens
#          get :show, :id => "37" , :space_id => @space.name
#          assigns[:attachment_children].should == []
#        end
#  
#        it "should return [] if no posts children" do
#          Post.stub!(:find).and_return(@public_children_post1) #give a children_post , which have not any childrens
#          get :show, :id => "37" , :space_id => @space.name
#          assigns[:comment_children].should == []
#        end
#      end
#    end
#  end
#
###########################################
#
#  describe "responding to GET new" do
#  
#    describe "when you are logged as " do
#    
#      describe "super admin" do
#      
#        before(:each) do
#          login_as(:user_admin)
#        end
#      
#        describe "in a private space" do
#          
#          before(:each) do
#            @space = spaces(:private_no_roles)
#            @new_post =  Post.new
#            @new_entry = Entry.new
#          end
#        
#          it "should have correct strings in session" do
#            get :new , :space_id => @space.name
#            session[:current_sub_tab].should eql("New post")
#          end
#        
#          it "should expose a new post as @post" do
#            Post.should_receive(:new).and_return(@new_post)
#            get :new , :space_id => @space.name
#            assigns[:post].should equal(@new_post)
#          end
#        
#          it "should have a title in @title" do
#            Post.should_receive(:new).and_return(@new_post)
#            get :new , :space_id => @space.name
#            assigns[:title].should_not eql(nil)
#            assigns[:title].should include("New Post")
#          end
#        
#          it "should have an associated entry " do
#            Post.should_receive(:new).and_return(@new_post)
#            @new_post.stub!(:entry).and_return(@new_entry)
#            get :new , :space_id => @space.name
#            assigns[:post].entry.should_not eql(nil)
#            assigns[:post].entry.should eql(@new_entry)
#          end
#        end
#      
#      
#        describe "in a pubic space" do
#          before(:each) do
#            @space = spaces(:public)
#            @new_post =  Post.new
#            @new_entry = Entry.new
#          end
#        
#          it "should have correct strings in session" do
#            get :new , :space_id => @space.name
#            session[:current_sub_tab].should eql("New post")
#          end
#        
#          it "should expose a new post as @post" do
#            Post.should_receive(:new).and_return(@new_post)
#            get :new , :space_id => @space.name
#            assigns[:post].should equal(@new_post)
#          end
#        
#          it "should have a title in @title" do
#            Post.should_receive(:new).and_return(@new_post)
#            get :new , :space_id => @space.name
#            assigns[:title].should_not == nil
#            assigns[:title].should include("New Post")
#          end
#        
#          it "should have an associated entry " do
#            Post.should_receive(:new).and_return(@new_post)
#            @new_post.stub!(:entry).and_return(@new_entry)
#            get :new , :space_id => @space.name
#            assigns[:post].entry.should_not eql(nil)
#            assigns[:post].entry.should eql(@new_entry)
#          end
#        end
#      end
#    
#      describe "normal User" do
#      
#        before(:each) do
#          login_as(:user_normal)
#        end
#        
#        describe "in a private space" do
#        
#          describe "where the user has the role Admin" do
#          
#            before(:each) do
#              @space = spaces(:private_admin)
#              @new_post =  Post.new
#              @new_entry = Entry.new
#            end
#          
#            it "should have correct strings in session" do
#              get :new , :space_id => @space.name
#              session[:current_sub_tab].should eql("New post")
#            end
#          
#            it "should expose a new post as @post" do
#              Post.should_receive(:new).and_return(@new_post)
#              get :new , :space_id => @space.name
#              assigns[:post].should equal(@new_post)
#            end
#          
#            it "should have a title in @title" do
#              Post.should_receive(:new).and_return(@new_post)
#              get :new , :space_id => @space.name
#              assigns[:title].should_not eql(nil)
#              assigns[:title].should include("New Post")
#            end
#          
#            it "should have an associated entry " do
#              Post.should_receive(:new).and_return(@new_post)
#              @new_post.stub!(:entry).and_return(@new_entry)
#              get :new , :space_id => @space.name
#              assigns[:post].entry.should_not eql(nil)
#              assigns[:post].entry.should eql(@new_entry)
#            end
#          end
#        
#          describe "where the user has the role User" do
#            
#            before(:each) do
#              @space = spaces(:private_user)
#              @new_post =  Post.new
#              @new_entry = Entry.new
#            end
#          
#            it "should have correct strings in session" do
#              get :new , :space_id => @space.name
#              session[:current_sub_tab].should eql("New post")
#            end
#          
#            it "should expose a new post as @post" do
#              Post.should_receive(:new).and_return(@new_post)
#              get :new , :space_id => @space.name
#              assigns[:post].should equal(@new_post)
#            end
#          
#            it "should have a title in @title" do
#              Post.should_receive(:new).and_return(@new_post)
#              get :new , :space_id => @space.name
#              assigns[:title].should_not eql(nil)
#              assigns[:title].should include("New Post")
#            end
#          
#            it "should have an associated entry " do
#              Post.should_receive(:new).and_return(@new_post)
#              @new_post.stub!(:entry).and_return(@new_entry)
#              get :new , :space_id => @space.name
#              assigns[:post].entry.should_not eql(nil)
#              assigns[:post].entry.should eql(@new_entry)
#            end
#          end
#        
#          describe "where the user has the role Invited" do
#            
#            before(:each) do
#              @space = spaces(:private_invited)
#              @new_post =  Post.new
#            end
#          
#            it "should not let the user do the action" do
#              get :new , :space_id => @space.name
#              assert_response 403
#            end
#          
#            it "should not have @post, @entry, @title, session[:current_sub_tab]" do
#              get :new , :space_id => @space.name
#              assigns[:title].should eql(nil)
#              session[:current_sub_tab].should eql(nil)
#              assigns[:post].should eql(nil)
#              session[:entry].should eql(nil)
#            end
#          end
#        
#          describe "where the user has no roles" do
#            
#            before(:each) do
#              @space = spaces(:private_no_roles)
#              @new_post =  Post.new
#            end
#          
#            it "should not let the user do the action" do
#              get :new , :space_id => @space.name
#              assert_response 403
#            end
#            
#            it "should not have @post, @entry, @title, session[:current_sub_tab]" do
#              get :new , :space_id => @space.name
#              assigns[:title].should eql(nil)
#              session[:current_sub_tab].should eql(nil)
#              assigns[:post].should eql(nil)
#              session[:entry].should eql(nil)
#            end
#          end
#        end
#      
#        describe "in the public space" do
#          
#          before(:each) do
#            @space = spaces(:public)
#            @new_post =  Post.new
#            @new_entry = Entry.new
#          end
#
#          it "should not let the user do the action" do
#            get :new , :space_id => @space.name
#            assert_response 403
#          end
#        end
#      end
#    end
#    
#    describe "if you are not logged in" do
#    
#      describe "a private space" do
#        
#        before(:each) do
#          @space = spaces(:private_no_roles)
#        end
#        
#        it "should not let the user do the action" do
#          get :new , :space_id => @space.name
#          assert_response 403
#        end
#        
#        it "should not have @post, @entry, @title, session[:current_sub_tab]" do
#          get :new , :space_id => @space.name
#          assigns[:title].should eql(nil)
#          session[:current_sub_tab].should eql(nil)
#          assigns[:post].should eql(nil)
#          session[:entry].should eql(nil)
#        end
#      end
#    
#      describe "the public space" do
#        
#        before(:each) do
#          @space = spaces(:public)
#        end
#      
#        it "should not let the user do the action" do
#          get :new , :space_id => @space.name
#          assert_response 403
#        end
#        
#        it "should not have @post, @entry, @title, session[:current_sub_tab]" do
#          get :new , :space_id => @space.name
#          assigns[:title].should eql(nil)
#          session[:current_sub_tab].should eql(nil)
#          assigns[:post].should eql(nil)
#          session[:entry].should eql(nil)
#        end
#      end
#    end
#  end
#
######################################
#
#  describe "responding to GET edit" do
#  
#    describe "when you are login as" do
#    
#      describe "superadmin" do
#        ### the superadmin can edit all posts of the aplication
#        
#        before(:each)do
#          login_as(:user_admin)
#        end
#    
#        describe "in a private space" do
#          
#          before(:each)do
#            @space = spaces(:private_no_roles)
#            @parent_post = posts(:parent_private_no_roles_post)
#            @children1_post = posts(:children_private_no_roles_post1)
#          end
#    
#          it "should expose the requested post as @post" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :edit, :id => "37" , :space_id => @space.name
#            assigns[:post].should equal(@parent_post)
#          end
#    
#          it "should have an associated entry " do
#            Post.stub!(:find).and_return(@parent_post)
#            get :edit ,:id=> "37", :space_id => @space.name
#            assigns[:post].entry.should_not eql(nil)
#            assigns[:post].entry.should eql(@parent_post.entry)
#          end
#    
#          it "should return the entries with attachment in @attachment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#            get :edit, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == [entries(:entry_private_no_roles_attachment_children3)]
#          end
#    
#          it "should return [] if no attachments children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :edit, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == []
#          end
#        end
#     
#        describe "in the public space" do
#       
#          before(:each)do
#            @space = spaces(:public)
#            @parent_post = posts(:public_post)
#            @children1_post = posts(:public_children_post1)
#          end
#       
#          it "should expose the requested post as @post" do
#            Post.stub!(:find).and_return(@parent_post)
#            get :edit, :id => "37" , :space_id => @space.name
#            assigns[:post].should equal(@parent_post)
#          end
#    
#          it "should have an associated entry " do
#            Post.stub!(:find).and_return(@parent_post)
#            get :edit ,:id=> "37", :space_id => @space.name
#            assigns[:post].entry.should_not eql(nil)
#            assigns[:post].entry.should eql(@parent_post.entry)
#          end
#    
#          it "should return the entries with attachment in @attachment_children" do
#            Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#            get :edit, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == [entries(:entry_public_attachment_children3)]
#          end
#    
#          it "should return [] if no attachments children" do
#            Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#            get :edit, :id => "37" , :space_id => @space.name
#            assigns[:attachment_children].should == []
#          end
#        end
#      end
#  
#      describe "normal user" do
#    
#        before(:each)do
#          login_as(:user_normal)
#        end
#  
#        describe "in a private space" do
#      
#          describe "where the user has the role Admin" do
#        
#            before(:each)do
#              @space = spaces(:private_user)
#            end
#        
#            describe "and the post not belongs to him" do
#            
#              before(:each)do
#                @parent_post = posts(:parent_private_admin_post)
#                @children1_post = posts(:children_private_admin_post1)
#              end
#         
#              it "should expose the requested post as @post" do
#                get :edit, :id => @parent_post.id , :space_id => @space.name
#                assigns[:post].should eql(@parent_post)
#              end
#    
#              it "should have an associated entry " do
#                get :edit ,:id=> @parent_post.id , :space_id => @space.name
#                assigns[:post].entry.should_not eql(nil)
#                assigns[:post].entry.should eql(@parent_post.entry)
#              end
#    
#              it "should return the entries with attachment in @attachment_children" do
#                Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#                get :edit, :id => "37" , :space_id => @space.name
#                assigns[:attachment_children].should == [entries(:entry_private_admin_attachment_children3)]
#              end
#    
#              it "should return [] if no attachments children" do
#                Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#                get :edit, :id => "37" , :space_id => @space.name
#                assigns[:attachment_children].should == []
#              end
#            end
#        
#            describe "and the post belongs to him" do
#            
#              before(:each)do
#                @parent_post = posts(:parent_private_normal_admin_post)
#                @children1_post = posts(:children_private_normal_admin_post1)
#              end
#         
#              it "should expose the requested post as @post" do
#                get :edit, :id => @parent_post.id , :space_id => @space.name
#                assigns[:post].should eql(@parent_post)
#              end
#    
#              it "should have an associated entry " do
#                get :edit ,:id=> @parent_post.id , :space_id => @space.name
#                assigns[:post].entry.should_not eql(nil)
#                assigns[:post].entry.should eql(@parent_post.entry)
#              end
#    
#              it "should return the entries with attachment in @attachment_children" do
#                Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#                get :edit, :id => "37" , :space_id => @space.name
#                assigns[:attachment_children].should == [entries(:entry_private_normal_admin_attachment_children3)]
#              end
#    
#              it "should return [] if no attachments children" do
#                Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#                get :edit, :id => "37" , :space_id => @space.name
#                assigns[:attachment_children].should == []
#              end
#            end
#          end  
#          
#          describe "where the user has the role User" do
#        
#            before(:each)do
#              @space = spaces(:private_user)
#            end
#        
#            describe "and the post not belongs to him" do
#        
#              before(:each)do
#                @parent_post = posts(:parent_private_user_post)
#                @children1_post = posts(:children_private_user_post1)
#              end
#         
#              it "should not let user to edit an post" do
#                get :edit , :id =>@parent_post, :space_id => @space.name 
#                assert_response 403
#              end
#            end
#        
#            describe "and the post belongs to him" do
#            
#              before(:each)do
#                @parent_post = posts(:parent_private_normal_user_post)
#                @children1_post = posts(:children_private_normal_user_post1)
#              end
#        
#              it "should expose the requested post as @post" do
#                get :edit, :id => @parent_post.id , :space_id => @space.name
#                assigns[:post].should eql(@parent_post)
#              end
#    
#              it "should have an associated entry " do
#                get :edit ,:id=> @parent_post.id , :space_id => @space.name
#                assigns[:post].entry.should_not eql(nil)
#                assigns[:post].entry.should eql(@parent_post.entry)
#              end
#    
#              it "should return the entries with attachment in @attachment_children" do
#                Post.stub!(:find).and_return(@parent_post) # give the parent post, which have 3 childrens
#                get :edit, :id => "37" , :space_id => @space.name
#                assigns[:attachment_children].should == [entries(:entry_private_normal_user_attachment_children3)]
#              end
#    
#              it "should return [] if no attachments children" do
#                Post.stub!(:find).and_return(@children1_post) #give a children_post , which have not any childrens
#                get :edit, :id => "37" , :space_id => @space.name
#                assigns[:attachment_children].should == []
#              end
#            end
#          end
#    
#          describe"where the user has the role Invited" do
#       
#            before(:each)do
#              @space = spaces(:private_invited)
#            end  
#                         
#            describe "and the post not belongs to him" do
#      
#              before(:each)do
#                @private_post = posts(:parent_private_invited_post)
#              end
#      
#              it "should not let user to edit an post" do
#                get :edit , :id =>@private_post, :space_id => @space.name 
#                assert_response 403
#              end
#            end
#            
#            describe "and the post belongs to him" do
#              
#              before(:each)do
#                @private_post = posts(:parent_private_normal_invited_post)
#              end
#      
#              it "should not let the user to edit this post" do
#                get :edit , :id =>@private_post, :space_id => @space.name 
#                assert_response 403
#              end
#            end
#          end
#    
#          describe"where the user has no roles on it" do
#      
#            before(:each)do
#              @space = spaces(:private_no_roles)
#            end
#            
#            describe "and the post not belongs to him" do
#           
#              before(:each)do
#                @private_post = posts(:parent_private_no_roles_post)
#              end 
#            
#              it "should not let user to edit an post" do
#                get :edit , :id =>@private_post.id, :space_id => @space.name 
#                assert_response 403
#              end
#            end
#        
#            describe "and the post belongs to him" do
#           
#              before(:each)do
#                @private_post = posts(:parent_private_normal_no_roles_post)
#              end 
#            
#              it "should not let the user to edit an post" do
#                get :edit , :id =>@private_post.id, :space_id => @space.name 
#                assert_response 403
#              end
#            end
#          end
#        
#   
#          describe "in the public space" do
#     
#            before(:each)do
#              @space = spaces(:public)
#            end
#            
#            describe "and the post not belongs to him" do
#              
#              before(:each)do
#                @parent_post = posts(:public_post)
#                @children1_post = posts(:public_children_post1)
#              end
#              
#              it "should not let user to edit an post" do
#                get :edit , :id =>@parent_post, :space_id => @space.name 
#                assert_response 403
#              end
#            end
#          
#            describe "and the post belongs to him" do
#              
#              before(:each)do
#                @parent_post = posts(:public_normal_post)
#                @children1_post = posts(:public_normal_children_post1)
#              end
#              
#              it "should let user to edit an post" do
#                pending("Esto se sale de las especificaciones, no?? El usuario normal no tiene rol de User o superior en Public") do
#                  get :edit , :id =>@parent_post, :space_id => @space.name 
#                  assert_response 200
#                end
#              end
#            end
#          end
#        end
#      end
#    end
#    
#    describe "if you are not logged in" do
#        
#      describe "a private space" do
#          
#        before(:each)do
#          @space = spaces(:private_no_roles)
#          @private_post = posts(:parent_private_no_roles_post)
#        end
#    
#        it "should not let user to edit an inexistent post" do
#          assert_raise ActiveRecord::RecordNotFound do
#            get :edit , :id =>"37777", :space_id => @space.name  
#          end
#        end
#       
#        it "should not let user to edit an existent post" do
#          get :edit , :id =>@private_post.id, :space_id => @space.name 
#          assert_response 403 
#        end
#      end
#     
#      describe "the public space" do
#          
#        before(:each)do
#          @space = spaces(:public)
#          @parent_post = posts(:public_post)
#        end
#        
#        it "should not let user to edit an inexistent post" do
#           ##este es el comportamiento normal de rails
#          assert_raise ActiveRecord::RecordNotFound do
#            get :edit , :id =>"37777", :space_id => @space.name  
#          end
#        end
#        
#        it "should not let user to edit an existent post" do
#          get :edit , :id =>@parent_post.id, :space_id => @space.name 
#          assert_response 403
#        end  
#      end
#    end
#  end
#
#
#
######################################################
#  describe "responding to POST create" do
#
#    describe "with valid params" do
#      before(:each) do
#       @valid_attributes = {:title => 'title', :text => 'text'}
#      end
#   
#      describe "when you are login as" do
#        describe "superadmin" do
#        
#          before(:each)do
#            login_as(:user_admin)
#          end
#        
#          describe "in a private space" do
#          
#            before(:each)do
#              @space = spaces(:private_no_roles)
#            end
#        
#            it "should expose a newly created post as @post" do
#              post :create, :post => @valid_attributes, :space_id => @space.name
#              assigns(:post).should_not equal(nil)
#              #assigns(:post).title.should equal(@valid_atributes[:title])
#            end
#        
#            it "should create a new post and a new Entry with valid params" do
#              assert_difference ['Post.count', 'Entry.count'] do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#              end
#            end
#
#            it "should redirect to the created post" do
#              post :create, :post => @valid_attributes, :space_id => @space.name
#              response.should redirect_to(space_post_url(@space,assigns(:post)))
#            end
#          end
#      
#          describe "in the public space" do
#          
#            before(:each)do
#              @space = spaces(:public)
#            end
#        
#            it "should expose a newly created post as @post" do
#              post :create, :post => @valid_attributes, :space_id => @space.name
#              assigns(:post).should_not equal(nil)
#              #assigns(:post).title.should equal(@valid_atributes[:title])
#            end
#        
#            it "should create a new post and a new Entry with valid params" do
#              assert_difference ['Post.count', 'Entry.count'] do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#              end
#            end
#
#            it "should redirect to the created post" do
#              post :create, :post => @valid_attributes, :space_id => @space.name
#              response.should redirect_to(space_post_url(@space,assigns(:post)))
#            end
#          end
#        end
#      
#        describe "normal user" do
#        
#          before(:each)do
#            login_as(:user_normal)
#          end
#      
#          describe "in a private space" do
#            
#            describe "where the user has the role Admin" do
#            
#              before(:each)do
#                @space = spaces(:private_admin)
#              end
#          
#              it "should expose a newly created post as @post" do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#                assigns(:post).should_not equal(nil)
#                #assigns(:post).title.should equal(@valid_atributes[:title])
#              end
#        
#              it "should create a new post and a new Entry with valid params" do
#                assert_difference ['Post.count', 'Entry.count'] do
#                  post :create, :post => @valid_attributes, :space_id => @space.name
#                end
#              end
#
#              it "should redirect to the created post" do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#                response.should redirect_to(space_post_url(@space,assigns(:post)))
#              end
#            end
#                                    
#            describe "where the user has the role User" do
#            
#              before(:each)do
#                @space = spaces(:private_user)
#              end
#          
#              it "should expose a newly created post as @post" do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#                assigns(:post).should_not equal(nil)
#                #assigns(:post).title.should equal(@valid_atributes[:title])
#              end
#        
#              it "should create a new post and a new Entry with valid params" do
#                assert_difference ['Post.count', 'Entry.count'] do
#                  post :create, :post => @valid_attributes, :space_id => @space.name
#                end
#              end
#
#              it "should redirect to the created post" do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#                response.should redirect_to(space_post_url(@space,assigns(:post)))
#              end
#            end
#        
#            describe"where the user has the role Invited" do
#          
#              before(:each)do
#                @space = spaces(:private_invited)
#              end
#          
#              it "should not let the user to create posts" do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#                assert_response 403
#                #assigns(:post).title.should equal(@valid_atributes[:title])
#              end
#            end
#          
#            describe"where the user has no roles" do
#            
#              before(:each)do
#                @space = spaces(:private_no_roles)
#              end
#          
#              it "should not let the user to create posts" do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#                assert_response 403
#                #assigns(:post).title.should equal(@valid_atributes[:title])
#              end
#            end
#          end
#        
#          describe "in the public space" do
#        
#            before(:each)do
#              @space = spaces(:public)
#            end
#            
#            it "should not let the user to create posts" do
#                post :create, :post => @valid_attributes, :space_id => @space.name
#                assert_response 403
#                #assigns(:post).title.should equal(@valid_atributes[:title])
#            end
#          end
#        end
#      end
#  
#      describe "if you are not logged in" do
#        describe "a private space" do
#        
#          before(:each)do
#            @space = spaces(:private_no_roles)
#          end
#      
#          it "should not let the user to create posts" do
#            post :create, :post => @valid_attributes, :space_id => @space.name
#            assert_response 403
#            #assigns(:post).title.should equal(@valid_atributes[:title])
#          end
#        end
#    
#        describe "the public space" do
#        
#          before(:each)do
#            @space = spaces(:public)
#          end
#      
#          it "should not let the user to create posts" do
#            post :create, :post => @valid_attributes, :space_id => @space.name
#            assert_response 403
#            #assigns(:post).title.should equal(@valid_atributes[:title])
#          end
#        end
#      end
#    end
#
#    describe "with invalid params" do
#  
#      before(:each) do
#        @valid_attributes = {:title => 'title', :text => 'text'}
#      end
#      
#      describe "when you are login as" do
#        
#        describe "superadmin" do
#        
#          before(:each)do
#            login_as(:user_admin)
#          end
#      
#          describe "in a private space" do
#        
#            before(:each)do
#              @space = spaces(:private_no_roles)
#            end
#
#            it "should re-render the 'new' template" do
#              post :create, :post => {}, :space_id => @space.name
#              response.should render_template('new')
#            end
#          end
#      
#          describe "in the public space" do
#        
#            before(:each)do
#              @space = spaces(:public)
#            end
#        
#            it "should re-render the 'new' template" do
#              post :create, :post => {}, :space_id => @space.name
#              response.should render_template('new')
#            end
#          end
#        end
#    
#        describe "normal user" do
#      
#          before(:each)do
#            login_as(:user_normal)
#          end
#      
#          describe "in a private space" do
#            
#            describe "where the user has the role Admin" do
#          
#              before(:each)do
#                @space = spaces(:private_admin)
#              end
#          
#              it "should re-render the 'new' template" do
#                post :create, :post => {}, :space_id => @space.name
#                response.should render_template('new')
#              end
#            end
#        
#        
#            describe "where the user has the role User" do
#          
#              before(:each)do
#                @space = spaces(:private_user)
#              end
#          
#              it "should re-render the 'new' template" do
#                post :create, :post => {}, :space_id => @space.name
#                response.should render_template('new')
#              end
#            end
#        
#            describe"where the user has the role Invited" do
#          
#              before(:each)do
#                @space = spaces(:private_invited)
#              end
#          
#              it "should not let the user to create posts" do
#                post :create, :post => {}, :space_id => @space.name
#                assert_response 403
#              end
#            end
#        
#            describe"where the user has no roles" do
#            
#              before(:each)do
#                @space = spaces(:private_no_roles)
#              end
#          
#              it "should not let the user to create posts" do
#                post :create, :post => {}, :space_id => @space.name
#                assert_response 403
#              end
#            end
#          end
#      
#          describe "in the public space" do
#        
#            before(:each)do
#              @space = spaces(:public)
#            end
#        
#            it "should not let the user to create posts" do
#              post :create, :post => {}, :space_id => @space.name
#              assert_response 403
#            end
#          end
#        end
#      end
#  
#      describe "if you are not logged in" do
#        describe "a private space" do
#          
#          before(:each)do
#            @space = spaces(:private_no_roles)
#          end
#      
#          it "should not let the user to create posts" do
#            post :create, :post => {}, :space_id => @space.name
#            assert_response 403
#          end
#        end
#    
#        describe "the public space" do
#      
#          before(:each)do
#            @space = spaces(:public)
#          end
#      
#          it "should not let the user to create posts" do
#            post :create, :post => {}, :space_id => @space.name
#            assert_response 403
#          end
#        end
#      end
#    end
#  end
#
#
###################################################
#
#  describe "responding to PUT udpate" do
#   
#    describe "with valid params" do
#  
#      before(:each) do
#        @valid_attributes = {:title => 'title', :text => 'text'}
#      end
#   
#      describe "when you are login as" do
#        describe "superadmin" do
#      
#          before(:each)do
#            login_as(:user_admin)
#          end
#        
#          describe "in a private space" do
#        
#            before(:each)do
#              @space = spaces(:private_no_roles)
#              @post = posts(:parent_private_no_roles_post)
#            end
#        
#            it "should let the user to edit the post" do
#              put :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#              response.should redirect_to(space_post_path(@space,@post))
#            end
#          end
#      
#          describe "in the public space" do
#        
#            before(:each)do
#              @space = spaces(:public)
#              @post = posts(:public_post)
#            end
#        
#            it "should let the user to edit the post" do
#              put :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#              response.should redirect_to(space_post_path(@space,@post))
#            end
#          end
#        end
#    
#        describe "normal user" do
#      
#          before(:each)do
#            login_as(:user_normal)
#          end
#      
#          describe "in a private space" do
#
#            describe "where the user has the role Admin" do
#          
#              before(:each)do
#                @space = spaces(:private_admin)
#              end
#            
#              describe "and the post not belongs to him" do
#            
#                before(:each)do
#                  @post = posts(:parent_private_admin_post)  
#                end
#           
#                it "should let the user to edit the post" do
#                  put :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                  response.should redirect_to(space_post_path(@space,@post))
#                end
#              end
#          
#              describe "and the post belongs to him" do
#            
#                before(:each)do
#                  @post = posts(:parent_private_normal_admin_post)  
#                end
#           
#                it "should let the user to edit the post" do
#                  put :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                  response.should redirect_to(space_post_path(@space,@post))
#                end
#              end
#            end        
#            describe "where the user has the role User" do
#          
#              before(:each)do
#                @space = spaces(:private_user)
#              end
#            
#              describe "and the post not belongs to him" do
#            
#                before(:each)do
#                  @post = posts(:parent_private_user_post)  
#                end
#           
#                it "should not let the user to edit the post" do
#                  put :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                  assert_response 403
#                end
#              end
#          
#              describe "and the post belongs to him" do
#            
#                before(:each)do
#                  @post = posts(:parent_private_normal_user_post)  
#                end
#           
#                it "should let the user to edit the post" do
#                  put :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                  response.should redirect_to(space_post_path(@space,@post))
#                end
#              end
#            end
#        
#            describe"where the user has the role Invited" do
#          
#              before(:each)do
#                @space = spaces(:private_invited)
#              end
#          
#              describe "and the post not belongs to him" do
#              
#                before(:each)do
#                  @post = posts(:parent_private_invited_post)
#                end
#              
#                it "should not let the user to edit posts" do
#                  post :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                  assert_response 403
#                end
#              end
#          
#              describe "and the post belongs to him" do
#              
#                before(:each)do
#                  @post = posts(:parent_private_normal_invited_post)
#                end
#               
#                it "should not let the user to edit the post" do
#                  put :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                  assert_response 403
#                end
#              end   
#            end
#      
#            describe"where the user has no roles" do
#          
#              before(:each)do
#                @space = spaces(:private_no_roles)
#                @post = posts(:parent_private_no_roles_post)
#              end
#            
#              describe "and the post not belongs to him" do
#          
#                before(:each)do
#                  @post = posts(:parent_private_no_roles_post)
#                end
#              
#                it "should not let the user to edit posts" do
#                  post :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                  assert_response 403
#                end
#              end
#          
#              describe "and the post belongs to him" do
#          
#                before(:each)do
#                  @post = posts(:parent_private_normal_no_roles_post)
#                end
#              
#                it "should not let the user to edit posts" do
#                  post :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                  assert_response 403
#                end
#              end
#            end
#          end
#      
#          describe "in the public space" do
#        
#            before(:each)do
#              @space = spaces(:public)
#            end
#           
#            describe "and the post not belongs to him" do
#              before(:each)do
#                @post = posts(:public_post)
#              end
#              
#              it "should not let the user to edit posts" do
#                post :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                assert_response 403
#              end
#            end
#        
#            describe "and the post belongs to him" do
#             
#              before(:each)do
#                @post = posts(:public_normal_post)
#              end
#              
#              it "should let the user to edit posts" do
#                post :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#                #response.should redirect_to(space_post_path(@space,@post))
#                assert_response 403
#              end
#            end
#          end
#        end
#      end
#  
#      describe "if you are not logged in" do
#    
#        describe "a private space" do
#      
#          before(:each)do
#            @space = spaces(:private_no_roles)
#            @post = posts(:parent_private_no_roles_post)
#          end
#      
#          it "should not let the user to edit posts" do
#            post :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#            assert_response 403
#          end
#        end
#    
#        describe "the public space" do
#      
#          before(:each)do
#            @space = spaces(:public)
#            @post = posts(:public_post)
#          end
#      
#          it "should not let the user to edit posts" do
#            post :update, :id => @post, :post => @valid_attributes, :space_id => @space.name
#            assert_response 403
#          end
#        end
#      end
#    end
#
#    describe "with invalid params" do
#
#      before(:each) do
#        @invalid_attributes = {}
#      end
#   
#      describe "when you are login as" do
#    
#        describe "superadmin" do
#      
#          before(:each)do
#            login_as(:user_admin)
#          end
#      
#          describe "in a private space" do
#        
#            before(:each)do
#              @space = spaces(:private_no_roles)
#              @post = posts(:parent_private_no_roles_post)
#            end
#        
#            it "should not let the user to edit the post and redirect to the post" do
#              put :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#              response.should redirect_to(space_post_url(@space,@post))
#            end
#          end
#        
#          describe "in the public space" do
#        
#            before(:each)do
#              @space = spaces(:public)
#              @post = posts(:public_post)
#            end
#        
#            it "should not let the user to edit the post and redirect to the post" do
#              put :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#              response.should redirect_to(space_post_url(@space,@post))
#            end
#          end
#        end
#    
#        describe "normal user" do
#      
#          before(:each)do
#            login_as(:user_normal)
#          end
#      
#          describe "in a private space" do
#
#            describe "where the user has the role Admin" do
#          
#              before(:each)do
#                @space = spaces(:private_admin)
#              end
#          
#              describe "and the post not belongs to him" do
#            
#                before(:each)do
#                  @post = posts(:parent_private_admin_post)  
#                end
#           
#                it "should not let the user to edit the post and redirect to the post" do
#                  put :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                  response.should redirect_to(space_post_path(@space,@post))
#                end
#              end
#          
#              describe "and the post belongs to him" do
#            
#                before(:each)do
#                  @post = posts(:parent_private_normal_admin_post)  
#                end
#           
#                it "should not let the user to edit the post and redirect to the post" do
#                  put :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                  response.should redirect_to(space_post_path(@space,@post))
#                end
#              end
#            end
#            
#            describe "where the user has the role User" do
#          
#              before(:each)do
#                @space = spaces(:private_user)
#              end
#          
#              describe "and the post not belongs to him" do
#            
#                before(:each)do
#                  @post = posts(:parent_private_user_post)  
#                end
#           
#                it "should not let the user to edit the post and redirect to the post" do
#                  put :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                  assert_response 403
#                end
#              end
#          
#              describe "and the post belongs to him" do
#            
#                before(:each)do
#                  @post = posts(:parent_private_normal_user_post)  
#                end
#           
#                it "should not let the user to edit the post and redirect to the post" do
#                  put :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                  response.should redirect_to(space_post_path(@space,@post))
#                end
#              end
#            end
#        
#            describe"where the user has the role Invited" do
#          
#              before(:each)do
#                @space = spaces(:private_invited)
#              end
#          
#              describe "and the post not belongs to him" do
#              
#                before(:each)do
#                  @post = posts(:parent_private_invited_post)
#                end
#              
#                it "should not let the user to edit posts" do
#                  post :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                  assert_response 403
#                end
#              end
#          
#              describe "and the post belongs to him" do
#              
#                before(:each)do
#                  @post = posts(:parent_private_normal_invited_post)
#                end
#               
#                it "should not let the user to edit the post " do
#                  put :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                  #response.should redirect_to(space_post_path(@space,@post))
#                  assert_response 403
#                end
#              end   
#            end
#      
#            describe"where the user has no roles" do
#          
#              before(:each)do
#                @space = spaces(:private_no_roles)
#                @post = posts(:parent_private_no_roles_post)
#              end
#          
#              describe "and the post not belongs to him" do
#          
#                before(:each)do
#                  @post = posts(:parent_private_no_roles_post)
#                end
#              
#                it "should not let the user to edit posts" do
#                  post :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                  assert_response 403
#                end
#              end
#          
#              describe "and the post belongs to him" do
#          
#                before(:each)do
#                  @post = posts(:parent_private_normal_no_roles_post)
#                end
#              
#                it "should not let the user to edit posts" do
#                  post :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                  #response.should redirect_to(space_post_path(@space,@post))
#                  assert_response 403
#                end
#              end
#            end
#          end
#        
#          describe "in the public space" do
#        
#            before(:each)do
#              @space = spaces(:public)
#            end
#           
#            describe "and the post not belongs to him" do
#              before(:each)do
#                @post = posts(:public_post)
#              end
#            
#              it "should not let the user to edit posts" do
#                post :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                assert_response 403
#              end
#            end
#        
#            describe "and the post belongs to him" do
#            
#              before(:each)do
#                @post = posts(:public_normal_post)
#              end
#            
#              it "should not let the user to edit posts" do
#                post :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#                #response.should redirect_to(space_post_path(@space,@post))
#                assert_response 403
#              end
#            end
#          end
#        end
#      end
#  
#      describe "if you are not logged in" do
#    
#        describe "a private space" do
#      
#          before(:each)do
#            @space = spaces(:private_no_roles)
#            @post = posts(:parent_private_no_roles_post)
#          end
#      
#          it "should not let the user to edit posts" do
#            post :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#            assert_response 403
#          end
#        end
#    
#        describe "the public space" do
#      
#          before(:each)do
#            @space = spaces(:public)
#            @post = posts(:public_post)
#          end
#      
#          it "should not let the user to edit posts" do
#            post :update, :id => @post, :post => @invalid_attributes, :space_id => @space.name
#            assert_response 403
#          end
#        end
#      end
#    end 
#  end
#
################################
#
#  describe "responding to DELETE destroy" do
#
#    describe "when you are login as" do
#      describe "superadmin" do
#      
#        before(:each)do
#          login_as(:user_admin)
#        end
#      
#        describe "in a private space" do
#          
#          before(:each)do
#            @space = spaces(:private_no_roles)
#            @post = posts(:parent_private_no_roles_post)
#          end
#        
#          it "should destroy the requested post" do
#            assert_difference 'Post.count', -3 do  #elimina el padre y los hijos
#              delete :destroy, :id => @post, :space_id => @space.name
#            end
#          end
#
#          it "should redirect to the posts list" do
#            delete :destroy, :id => @post, :space_id => @space.name
#            response.should redirect_to(space_posts_path(@space))
#          end
#        end
#      
#        describe "in the public space" do
#          
#          before(:each)do
#            @space = spaces(:public)
#            @post = posts(:public_post)
#          end
#        
#          it "should destroy the requested post" do
#            assert_difference 'Post.count', -3 do  #elimina el padre y los hijos
#              delete :destroy, :id => @post, :space_id => @space.name
#            end
#          end
#
#          it "should redirect to the posts list" do
#            delete :destroy, :id => @post, :space_id => @space.name
#            response.should redirect_to(space_posts_path(@space))
#          end
#        end
#      end
#    
#      describe "normal user" do
#        
#        before(:each)do
#          login_as(:user_normal)
#        end
#      
#        describe "in a private space" do
#          
#          describe "where the user has the role Admin" do
#          
#            before(:each)do
#              @space = spaces(:private_admin)
#            end
#          
#            describe "and the post not belongs to him" do
#            
#              before(:each)do
#                @post = posts(:parent_private_admin_post)  
#              end
#           
#              it "should destroy the requested post" do
#                assert_difference 'Post.count', -3 do  #elimina el padre y los hijos
#                  delete :destroy, :id => @post, :space_id => @space.name
#                end
#              end
#
#              it "should redirect to the posts list" do
#                delete :destroy, :id => @post, :space_id => @space.name
#                response.should redirect_to(space_posts_path(@space))
#              end
#            end
#          
#            describe "and the post belongs to him" do
#              
#              before(:each)do
#                @post = posts(:parent_private_normal_user_post)  
#              end
#           
#              it "should destroy the requested post" do
#                assert_difference 'Post.count', -3 do  #elimina el padre y los hijos
#                  delete :destroy, :id => @post, :space_id => @space.name
#                end
#              end
#
#              it "should redirect to the posts list" do
#                delete :destroy, :id => @post, :space_id => @space.name
#                response.should redirect_to(space_posts_path(@space))
#              end
#            end
#          end  
#        
#          describe "where the user has the role User" do
#          
#            before(:each)do
#              @space = spaces(:private_user)
#            end
#          
#            describe "and the post not belongs to him" do
#            
#              before(:each)do
#                @post = posts(:parent_private_user_post)  
#              end
#
#              it "should not let to destroy the requested post" do
#                  delete :destroy, :id => @post, :space_id => @space.name
#                  assert_response 403
#              end
#            end
#          
#            describe "and the post not belongs to him" do
#              
#              before(:each)do
#                @post = posts(:parent_private_normal_user_post)  
#              end
#           
#              it "should destroy the requested post" do
#                assert_difference 'Post.count', -3 do  #elimina el padre y los hijos
#                  delete :destroy, :id => @post, :space_id => @space.name
#                end
#              end
#              
#              it "should redirect to the posts list" do
#                delete :destroy, :id => @post, :space_id => @space.name
#                response.should redirect_to(space_posts_path(@space))
#              end
#            end
#          end    
#        
#          describe"where the user has the role Invited" do
#          
#            before(:each)do
#              @space = spaces(:private_invited)
#            end
#          
#            describe "and the post not belongs to him" do
#              
#              before(:each)do
#                @post = posts(:parent_private_invited_post)
#              end
#              
#              it "should not destroy the requested post" do
#                assert_no_difference 'Post.count' do  #elimina el padre y los hijos
#                delete :destroy, :id => @post, :space_id => @space.name
#                end
#              end
#              
#              it "should not redirect to the posts list" do
#                delete :destroy, :id => @post, :space_id => @space.name
#                assert_response 403
#              end
#            end
#        
#            describe "and the post belongs to him" do
#              
#              before(:each)do
#                @post = posts(:parent_private_normal_invited_post)
#              end
#              
#              it "should not destroy the requested post" do
#                #assert_difference 'Post.count', -3 do  #elimina el padre y los hijos
#                  delete :destroy, :id => @post, :space_id => @space.name
#                  assert_response 403
#                #end
#              end          
#            end    
#          end
#      
#          describe"where the user has no roles" do
#            
#            before(:each)do
#              @space = spaces(:private_no_roles)
#              @post = posts(:parent_private_no_roles_post)
#            end
#          
#            describe "and the post not belongs to him" do
#          
#              before(:each)do
#                @post = posts(:parent_private_no_roles_post)
#              end
#              
#              it "should not destroy the requested post" do
#                assert_no_difference 'Post.count' do  #elimina el padre y los hijos
#                  delete :destroy, :id => @post, :space_id => @space.name
#                end
#              end
#              
#              it "should not redirect to the posts list" do
#                delete :destroy, :id => @post, :space_id => @space.name
#                assert_response 403
#              end
#            end
#          
#            describe "and the post belongs to him" do
#          
#              before(:each)do
#                @post = posts(:parent_private_normal_no_roles_post)
#              end
#             
#              it "should not destroy the requested post" do
#                #assert_difference 'Post.count', -3 do  #elimina el padre y los hijos
#                  delete :destroy, :id => @post, :space_id => @space.name
#                  assert_response 403
#                #end
#              end             
#            end
#          end
#        end
#      
#        describe "in the public space" do
#          
#          before(:each)do
#            @space = spaces(:public)
#          end
#           
#          describe "and the post not belongs to him" do
#          
#            before(:each)do
#              @post = posts(:public_post)
#            end
#            
#            it "should not destroy the requested post" do
#              assert_no_difference 'Post.count' do  #elimina el padre y los hijos
#                delete :destroy, :id => @post, :space_id => @space.name
#              end
#            end
#            
#            it "should not redirect to the posts list" do
#              delete :destroy, :id => @post, :space_id => @space.name
#              assert_response 403
#            end
#          end
#        
#          describe "and the post belongs to him" do
#            
#            before(:each)do
#              @post = posts(:public_normal_post)
#            end
#            
#            it "should not destroy the requested post" do
#              #assert_difference 'Post.count', -3 do  #elimina el padre y los hijos
#                delete :destroy, :id => @post, :space_id => @space.name
#                assert_response 403
#              #end
#            end            
#          end
#        end
#      end
#    end
#  
#    describe "if you are not logged in" do
#      describe "a private space" do
#        
#        before(:each)do
#          @space = spaces(:private_no_roles)
#          @post = posts(:parent_private_no_roles_post)
#        end
#      
#        it "should not destroy the requested post" do
#          assert_no_difference 'Post.count' do  #elimina el padre y los hijos
#            delete :destroy, :id => @post, :space_id => @space.name
#          end
#        end
#       
#        it "should not redirect to the posts list" do
#          delete :destroy, :id => @post, :space_id => @space.name
#          assert_response 403
#        end
#      end
#    
#      describe "the public space" do
#        
#        before(:each)do
#          @space = spaces(:public)
#          @post = posts(:public_post)
#        end
#      
#        it "should not destroy the requested post" do
#          assert_no_difference 'Post.count' do  #elimina el padre y los hijos
#            delete :destroy, :id => @post, :space_id => @space.name
#          end
#        end
#        
#        it "should not redirect to the posts list" do
#          delete :destroy, :id => @post, :space_id => @space.name
#          assert_response 403
#        end
#      end
#    end
#  end
