module ActionController #:nodoc:
  # Authentication helper methods for tests
  module AuthenticationTestHelper
    # Sets the current agent in the session from the argument or fixtures.
    def login_as(agent)
      agent_fixture = find_agent_fixture(agent)

      session[:agent_id] = agent_fixture ? agent_fixture.id : nil
      session[:agent_type] = agent_fixture ? agent_fixture.class.to_s : nil
    end

    # Sets HTTP environment credentials
    def authorize_as(agent)
      agent_fixture = find_agent_fixture(agent)

      request.env["HTTP_AUTHORIZATION"] = agent_fixture ? ActionController::HttpAuthentication::Basic.encode_credentials(agent_fixture.login, 'test') : nil
    end

    # Is there any agent authenticated?
    def authenticated?
      session[:agent_id] && session[:agent_type]
    end

    # Agent currently authenticated
    def current_agent
      assigns[:current_agent]
    end

    private

    # Finds agent fixture among agent classes
    def find_agent_fixture(agent)
      return nil unless agent

      return agent unless agent.is_a?(Symbol)

      ( ActiveRecord::Agent.symbols - [ :singular_agents ] ).each do |agent_klass|
        agent_fixture = send(agent_klass, agent)
        return agent_fixture if agent_fixture
      end
      nil
    end
  end
end
