# Verifies that the action to be called can NOT be accessed.
# Arguments:
#   do_action: the action to be called
#
# Example:
#   let(:do_action) { get :show, :id => site }
#   it_should_behave_like "it cannot access an action"
#
shared_examples_for "it cannot access an action" do
  it { expect { do_action }.to raise_error(CanCan::AccessDenied) }
end

# Verifies that the action to be called CAN be accessed.
# Arguments:
#   do_action    # the action to be called
#
shared_examples_for "it can access an action" do
  it { expect { do_action }.to_not raise_error }
  context do
    before(:each) { do_action }
    it { [200, 302].should include(response.response_code) }
  end
end
