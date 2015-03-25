# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe PostsController do
  render_views

  it "#index"
  it "#show"
  it "#new"
  it "#create"

  describe "#update" do
    let!(:post) { FactoryGirl.create(:post) }
    let(:user) { post.author }
    let(:space) { post.space }
    before do
      space.add_member!(user)
      sign_in(user)
    end

    # it { should_authorize an_instance_of(Post), :update, via: :put, id: post.id, space_id: space.to_param, :post => {} }

    context "params_handling" do
      let(:post_attributes) { FactoryGirl.attributes_for(:post) }
      let(:params) {
        {
          id: post.id,
          space_id: space.to_param,
          controller: "posts",
          action: "update",
          post: post_attributes
        }
      }

      let(:post_allowed_params) {
        [:title, :text, :parent_id]
      }
      before {
        post_attributes.stub(:permit).and_return(post_attributes)
        controller.stub(:params).and_return(params)
      }
      before(:each) {
        expect {
          put :update, id: post.to_param, space_id: space.to_param, post: post_attributes
        }.to change { RecentActivity.count }.by(1)
      }
      it { post_attributes.should have_received(:permit).with(*post_allowed_params) }
      it { should redirect_to(space_posts_path(space)) }
      it { should set_the_flash.to(I18n.t("post.updated")) }
    end

    context "changing no parameters" do
      before(:each) {
        expect {
          put :update, id: post.to_param, space_id: space.to_param, :post => {}
        }.not_to change { RecentActivity.count }
      }

      it { should redirect_to(space_posts_path(space)) }
      it { should set_the_flash.to(I18n.t("post.updated")) }
    end

    context "changing some parameters" do
      let(:post_params) { {title: "#{post.title}_new", text: "#{post.text} new" } }
      before(:each) {
        expect {
          put :update, id: post.to_param, space_id: space.to_param, post: post_params
        }.to change { RecentActivity.count }.by(1)
      }

      it { RecentActivity.last.key.should eq('post.update') }
      it { RecentActivity.last.parameters[:changed_attributes].should eq(['title', 'text']) }
      it { should redirect_to(space_posts_path(space)) }
      it { should set_the_flash.to(I18n.t("post.updated")) }
    end
  end

  it "#edit"
  it "#destroy"
  it "#reply_post"

  describe "include SpamControllerModule" do
    it "#spam_report_create"
  end

  describe "abilities", :abilities => true do
    it "abilities"
  end
end
