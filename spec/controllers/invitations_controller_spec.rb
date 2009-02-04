require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvitationsController do
  include ActionController::AuthenticationTestHelper
  fixtures :users, :spaces

  describe "responding to GET new" do
    describe "when you are logged in" do
      describe "as SuperAdmin" do
        before(:each) do
          login_as(:user_admin)
        end

        describe "in a private space" do
          before(:each) do
            @space = spaces(:private_no_roles)
          end
          it "should show new form " do
            get :new, :space_id => @space.to_param
            assert_response 200
            response.should render_template('new')
          end
        end

        describe "in private_user space" do
          before(:each) do
            @space = spaces(:private_user)
            @invited = users(:user_normal)
            @valid_email = "pepe@example.com"
            @invalid_email = "mat@invalid"
          end

          it "should process emails" do
            post :create, 
                 :email_list => "#{ @valid_email}, \"Normalillo\" <#{ @invited.email }>, #{ @invalid_email }",
                 :role => "Invited",
                 :space_id => @space.to_param

            assert_response 200
            assigns(:users_invited).should include(@valid_email)
            assigns(:users_not_added).should include(@invited.email)
            assigns(:emails_invalid).should include(@invalid_email) 
          end
        end
      end
    end
  end
end

