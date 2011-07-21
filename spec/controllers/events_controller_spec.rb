require "spec_helper"

#Include tests combination of:
#  methods: index, show, update, delete
#  spaces:  public, private
#  events:  in person
#  author:  true, false
#  users:   admin, user, invited, not logged in


describe EventsController do
  include ActionController::AuthenticationTestHelper
  render_views

  describe "when you are logged as" do

    #### Space Admin User  ####
    describe "space admin user" do
      describe "and you are in a public space" do
        before(:each) do
          @current_space = Factory(:public_space)
          @performace_universe = Factory(:admin_performance, :stage => @current_space)
          @current_user = @performace_universe.agent
          @current_event_mine = Factory(:event, :space => @current_space, :author => @current_user)
          @current_event_other = Factory(:event, :space => @current_space, :author => Factory(:user_performance, :stage => @current_space).agent)
          login_as(@current_user)
        end

        it "should render index" do
          get :index, :space_id => @current_space.to_param
          assert_response 200
          response.should render_template("events/index")
        end

        describe "should render show of" do
          it "my own event" do
            get :show, :space_id => @current_event_mine.space.to_param, :id => @current_event_mine.to_param
            assert_response 200
            response.should render_template("events/show")
          end
          it "other's event" do
            get :show, :space_id => @current_event_other.space.to_param, :id => @current_event_other.to_param
            assert_response 200
            response.should render_template("events/show")
          end
        end

        it "trying to create a new event" do
          valid_attributes = Factory.attributes_for(:event)
          post :create, :space_id => @current_space.to_param, :event => valid_attributes
          assert_response 302
          event = Event.find_by_name(valid_attributes[:name])
          response.should redirect_to(space_events_path(@current_space))
        end

        describe "trying to update" do
          it "my event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_mine.to_param, :event => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_event_path(@current_space, Event.find_by_id(@current_event_mine.id)))
            flash[:success].should == I18n.t('event.updated')
          end
          it "other's event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_other.to_param, :event => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_event_path(@current_space, Event.find_by_id(@current_event_other.id)))
            flash[:success].should == I18n.t('event.updated')
          end
        end

        describe "trying to delete" do
          it "my event." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_mine.to_param
            assert_response 302
            response.should redirect_to(space_events_path)
            flash[:success].should == I18n.t('event.deleted')
            assert_nil Event.find_by_id(@current_event_mine.id)
          end
          it "a event that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_other.to_param
            assert_response 302
            response.should redirect_to(space_events_path)
            flash[:success].should == I18n.t('event.deleted')
            assert_nil Event.find_by_id(@current_event_other.id)
          end
        end

      end
      describe "and you are in a private space" do
        before(:each) do
          @current_space = Factory(:private_space)
          @performace_universe = Factory(:admin_performance, :stage => @current_space)
          @current_user = @performace_universe.agent
          @current_event_mine = Factory(:event, :space => @current_space, :author => @current_user)
          @current_event_other = Factory(:event, :space => @current_space, :author => Factory(:user_performance, :stage => @current_space).agent)
          login_as(@current_user)
        end

        it "should render index" do
          get :index, :space_id => @current_space.to_param
          assert_response 200
          response.should render_template("events/index")
        end

        describe "should render show of" do
          it "my own event" do
            get :show, :space_id => @current_event_mine.space.to_param, :id => @current_event_mine.to_param
            assert_response 200
            response.should render_template("events/show")
          end
          it "other's event" do
            get :show, :space_id => @current_event_other.space.to_param, :id => @current_event_other.to_param
            assert_response 200
            response.should render_template("events/show")
          end
        end

        it "trying to create a new event." do
          valid_attributes = Factory.attributes_for(:event)
          post :create, :space_id => @current_space.to_param, :event => valid_attributes
          assert_response 302
          event = Event.find_by_name(valid_attributes[:name])
          response.should redirect_to(space_events_path(@current_space))
        end

        describe "trying to update" do
          it "my event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_mine.to_param, :event => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_event_path(@current_space, Event.find_by_id(@current_event_mine.id)))
            flash[:success].should == I18n.t('event.updated')
          end
          it "other's event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_other.to_param, :event => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_event_path(@current_space, Event.find_by_id(@current_event_other.id)))
            flash[:success].should == I18n.t('event.updated')
          end
        end

        describe "trying to delete" do
          it "my event." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_mine.to_param
            assert_response 302
            response.should redirect_to(space_events_path)
            flash[:success].should == I18n.t('event.deleted')
            assert_nil Event.find_by_id(@current_event_mine.id)
          end
          it "a event that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_other.to_param
            assert_response 302
            response.should redirect_to(space_events_path)
            flash[:success].should == I18n.t('event.deleted')
            assert_nil Event.find_by_id(@current_event_other.id)
          end
        end
      end
    end

    #### Space User  ####
    describe "space user" do
      describe "and you are in a public space" do
        before(:each) do
          @current_space = Factory(:public_space)
          @performace_universe = Factory(:user_performance, :stage => @current_space)
          @current_user = @performace_universe.agent
          @current_event_mine = Factory(:event, :space => @current_space, :author => @current_user)
          @current_event_other = Factory(:event, :space => @current_space, :author => Factory(:user_performance, :stage => @current_space).agent)
          login_as(@current_user)
        end

        it "should render index" do
          get :index, :space_id => @current_space.to_param
          assert_response 200
          response.should render_template("events/index")
        end

        describe "should render show of" do
          it "my own event" do
            get :show, :space_id => @current_event_mine.space.to_param, :id => @current_event_mine.to_param
            assert_response 200
            response.should render_template("events/show")
          end
          it "other's event" do
            get :show, :space_id => @current_event_other.space.to_param, :id => @current_event_other.to_param
            assert_response 200
            response.should render_template("events/show")
          end
        end

        it "trying to create a new event" do
          valid_attributes = Factory.attributes_for(:event)
          post :create, :space_id => @current_space.to_param, :event => valid_attributes
          assert_response 302
          event = Event.find_by_name(valid_attributes[:name])
          response.should redirect_to(space_events_path(@current_space))
        end

        describe "trying to update" do
          it "my event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_mine.to_param, :event => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_event_path(@current_space, Event.find_by_id(@current_event_mine.id)))
            flash[:success].should == I18n.t('event.updated')
          end
          it "other's event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_other.to_param, :event => valid_attributes, :format => 'html'
            assert_response 403
          end
        end

        describe "trying to delete" do
          it "my event." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_mine.to_param
            assert_response 302
            response.should redirect_to(space_events_path)
            flash[:success].should == I18n.t('event.deleted')
            assert_nil Event.find_by_id(@current_event_mine.id)
          end
          it "a event that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_other.to_param
            assert_response 403
          end
        end

      end
      describe "and you are in a private space" do
        before(:each) do
          @current_space = Factory(:private_space)
          @performace_universe = Factory(:user_performance, :stage => @current_space)
          @current_user = @performace_universe.agent
          @current_event_mine = Factory(:event, :space => @current_space, :author => @current_user)
          @current_event_other = Factory(:event, :space => @current_space, :author => Factory(:user_performance, :stage => @current_space).agent)
          login_as(@current_user)
        end

        it "should render index" do
          get :index, :space_id => @current_space.to_param
          assert_response 200
          response.should render_template("events/index")
        end

        describe "should render show of" do
          it "my own event" do
            get :show, :space_id => @current_event_mine.space.to_param, :id => @current_event_mine.to_param
            assert_response 200
            response.should render_template("events/show")
          end
          it "other's event" do
            get :show, :space_id => @current_event_other.space.to_param, :id => @current_event_other.to_param
            assert_response 200
            response.should render_template("events/show")
          end
        end

        it "trying to create a new event." do
          valid_attributes = Factory.attributes_for(:event)
          post :create, :space_id => @current_space.to_param, :event => valid_attributes
          assert_response 302
          event = Event.find_by_name(valid_attributes[:name])
          response.should redirect_to(space_events_path(@current_space))
        end

        describe "trying to update" do
          it "my event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_mine.to_param, :event => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_event_path(@current_space, Event.find_by_id(@current_event_mine)))
            flash[:success].should == I18n.t('event.updated')
          end
          it "other's event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_other.to_param, :event => valid_attributes, :format => 'html'
            assert_response 403
          end
        end

        describe "trying to delete" do
          it "my event." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_mine.to_param
            assert_response 302
            response.should redirect_to(space_events_path)
            flash[:success].should == I18n.t('event.deleted')
            assert_nil Event.find_by_id(@current_event_mine.id)
          end
          it "a event that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_other.to_param
            assert_response 403
          end
        end
      end
    end

    #### Space invited User  ####
    describe "space invited user" do
      describe "and you are in a public space" do
        before(:each) do
          @current_space = Factory(:public_space)
          @performace_universe = Factory(:invited_performance, :stage => @current_space)
          @current_user = @performace_universe.agent
          @current_event_mine = Factory(:event, :space => @current_space, :author => @current_user)
          @current_event_other = Factory(:event, :space => @current_space, :author => Factory(:user_performance, :stage => @current_space).agent)
          login_as(@current_user)
        end

        it "should render index" do
          get :index, :space_id => @current_space.to_param
          assert_response 200
          response.should render_template("events/index")
        end

        describe "should render show of" do
          it "my own event" do
            get :show, :space_id => @current_event_mine.space.to_param, :id => @current_event_mine.to_param
            assert_response 200
            response.should render_template("events/show")
          end
          it "other's event" do
            get :show, :space_id => @current_event_other.space.to_param, :id => @current_event_other.to_param
            assert_response 200
            response.should render_template("events/show")
          end
        end

        it "trying to create a new event" do
          valid_attributes = Factory.attributes_for(:event)
          post :create, :space_id => @current_space.to_param, :event => valid_attributes
          assert_response 403
        end

        describe "trying to update" do
          it "my event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_mine.to_param, :event => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_event_path(@current_space, Event.find_by_id(@current_event_mine)))
            flash[:success].should == I18n.t('event.updated')
          end
          it "other's event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_other.to_param, :event => valid_attributes, :format => 'html'
            assert_response 403
          end
        end

        describe "trying to delete" do
          it "my event." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_mine.to_param
            assert_response 302
            response.should redirect_to(space_events_path)
            flash[:success].should == I18n.t('event.deleted')
            assert_nil Event.find_by_id(@current_event_mine.id)
          end
          it "a event that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_other.to_param
            assert_response 403
          end
        end

      end
      describe "and you are in a private space" do
        before(:each) do
          @current_space = Factory(:private_space)
          @performace_universe = Factory(:invited_performance, :stage => @current_space)
          @current_user = @performace_universe.agent
          @current_event_mine = Factory(:event, :space => @current_space, :author => @current_user)
          @current_event_other = Factory(:event, :space => @current_space, :author => Factory(:user_performance, :stage => @current_space).agent)
          login_as(@current_user)
        end

        it "should render index" do
          get :index, :space_id => @current_space.to_param
          assert_response 200
          response.should render_template("events/index")
        end

        describe "should render show of" do
          it "my own event" do
            get :show, :space_id => @current_event_mine.space.to_param, :id => @current_event_mine.to_param
            assert_response 200
            response.should render_template("events/show")
          end
          it "other's event" do
            get :show, :space_id => @current_event_other.space.to_param, :id => @current_event_other.to_param
            assert_response 200
            response.should render_template("events/show")
          end
        end

        it "trying to create a new event." do
          valid_attributes = Factory.attributes_for(:event)
          post :create, :space_id => @current_space.to_param, :event => valid_attributes
          assert_response 403
        end

        describe "trying to update" do
          it "my event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_mine.to_param, :event => valid_attributes, :format => 'html'
            assert_response 302
            response.should redirect_to(space_event_path(@current_space, Event.find_by_id(@current_event_mine)))
            flash[:success].should == I18n.t('event.updated')
          end
          it "other's event." do
            valid_attributes = Factory.attributes_for(:event)
            post :update, :space_id => @current_space.to_param, :id => @current_event_other.to_param, :event => valid_attributes, :format => 'html'
            assert_response 403
          end
        end

        describe "trying to delete" do
          it "my event." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_mine.to_param
            assert_response 302
            response.should redirect_to(space_events_path)
            flash[:success].should == I18n.t('event.deleted')
            assert_nil Event.find_by_id(@current_event_mine.id)
          end
          it "a event that isn't mine." do
            delete :destroy, :space_id => @current_space.to_param, :id => @current_event_other.to_param
            assert_response 403
          end
        end
      end
    end

    #### Not logged in ####
    describe "not logged user" do
      describe "and you are in a public space" do
        before(:each) do
          @current_space = Factory(:public_space)
          @current_event = Factory(:event, :space => @current_space, :author => Factory(:user_performance, :stage => @current_space).agent)
        end

        it "should render index" do
          get :index, :space_id => @current_space.to_param
          assert_response 200
          response.should render_template("events/index")
        end

        it "should render show of an event." do
          get :show, :space_id => @current_event.space.to_param, :id => @current_event.to_param
          assert_response 200
          response.should render_template("events/show")
        end

        it "trying to create a new event" do
          valid_attributes = Factory.attributes_for(:event)
          post :create, :space_id => @current_space.to_param, :event => valid_attributes
          assert_response 302
          response.should redirect_to(new_session_path)
        end

        it "trying to update an event." do
          valid_attributes = Factory.attributes_for(:event)
          post :update, :space_id => @current_space.to_param, :id => @current_event.to_param, :event => valid_attributes
          assert_response 302
          response.should redirect_to(new_session_path)
        end

        it "trying to delete an event" do
          delete :destroy, :space_id => @current_space.to_param, :id => @current_event.to_param
          assert_response 302
          response.should redirect_to(new_session_path)
        end
      end

      describe "and you are in a private space" do
        before(:each) do
          @current_space = Factory(:private_space)
          @current_event = Factory(:event, :space => @current_space, :author => Factory(:user_performance, :stage => @current_space).agent)
        end

        it "should render index" do
          get :index, :space_id => @current_space.to_param
          assert_response 302
          response.should redirect_to(new_session_path)
        end

        it "should render show of an event." do
          get :show, :space_id => @current_event.space.to_param, :id => @current_event.to_param
          assert_response 302
          response.should redirect_to(new_session_path)
        end

        it "trying to create a new event" do
          valid_attributes = Factory.attributes_for(:event)
          post :create, :space_id => @current_space.to_param, :event => valid_attributes
          assert_response 302
          response.should redirect_to(new_session_path)
        end

        it "trying to update an event." do
          valid_attributes = Factory.attributes_for(:event)
          post :update, :space_id => @current_space.to_param, :id => @current_event.to_param, :event => valid_attributes
          assert_response 302
          response.should redirect_to(new_session_path)
        end

        it "trying to delete an event" do
          delete :destroy, :space_id => @current_space.to_param, :id => @current_event.to_param
          assert_response 302
          response.should redirect_to(new_session_path)
        end
      end

    end
  end
end

