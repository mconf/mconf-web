# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Example:
#   let(:do_action) { get :show, :id => site }
#   let(:user) { FactoryGirl.create(:user) }
#   it_should_behave_like "an action that renders a modal - signed in"
shared_examples_for "an action that renders a modal - signed in" do
  let(:request_path) { '/requested_path' }
  before { request.stub(:path) { request_path } }

  context "with a referer" do
    let(:referer) { "#{root_url}anything" }
    let(:expected) { "#{referer}?#{URI.encode_www_form({automodal: request_path})}" }
    before {
      request.env["HTTP_REFERER"] = referer
      login_as(user)
      do_action
    }
    it { should respond_with(302) }
    it { should redirect_to(expected) }
  end

  context "without a referer" do
    before {
      request.env["HTTP_REFERER"] = nil
      login_as(user)
      do_action
    }
    it { should respond_with(302) }
    it { should redirect_to(my_home_path(automodal: request_path)) }
  end
end

shared_examples_for "an action that renders a modal - not signed in" do
  context "with a referer" do
    let(:referer) { "#{root_url}anything" }
    before {
      request.env["HTTP_REFERER"] = referer
      do_action
    }
    it { should respond_with(302) }
    it { should redirect_to(expected) }
  end

  context "without a referer" do
    before {
      request.env["HTTP_REFERER"] = nil
      do_action
    }
    it { should respond_with(302) }
    it { should redirect_to(root_path) }
  end
end
