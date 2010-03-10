module ActiveRecord #:nodoc:
  # Helper methods for testing ActiveRecord::Authorization in Rspec
  #
  #   describe Resource
  #     extend ActiveRecord::AuthorizationTestHelper
  #
  #     describe "in some space" do
  #       before(:all) do
  #         @resource = Factory(:resource)
  #         @admin = Some.admin
  #       end
  #
  #       it_should_authorize(:admin, :update, :resource)
  #       it_should_not_authorize(Anonymous.current, :update, :resource)
  #     end
  #   end
  module AuthorizationTestHelper
    def it_should_authorize(agent_name, action, auth_object_name)
      it "should authorize #{ action } to #{ agent_name }" do
        auth_object = instance_variable_get("@#{ auth_object_name }")
        agent = ( agent_name.is_a?(Symbol) ?
                  instance_variable_get("@#{ agent_name }") :
                  agent_name )
        assert auth_object.authorize?(action, :to => agent)
      end
    end

    def it_should_not_authorize(agent_name, action, auth_object_name)
      it "should not authorize #{ action } to #{ agent_name }" do
        auth_object = instance_variable_get("@#{ auth_object_name }")
        agent = ( agent_name.is_a?(Symbol) ?
                  instance_variable_get("@#{ agent_name }") :
                  agent_name )
        assert ! auth_object.authorize?(action, :to => agent)
      end
    end
  end
end

