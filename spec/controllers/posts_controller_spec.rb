# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe PostsController do
  render_views

  let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
  let(:user) { FactoryGirl.create(:user) }

  context "#index" do
    before {
      @posts = [
        FactoryGirl.create(:post, space: space, updated_at: Time.now),
        FactoryGirl.create(:post, space: space, updated_at: Time.now + 1.second),
        FactoryGirl.create(:post, space: space, updated_at: Time.now + 2.second),
        FactoryGirl.create(:post, updated_at: Time.now + 99.second), # not in the same space
      ]
      get :index, space_id: space.to_param
    }

    skip { should_authorize Post, :index, space_id: space.to_param }

    it { should render_template('index') }
    it { should render_with_layout('spaces_show') }
    it { should assign_to(:space).with(space) }
    it {
      expected = [
        Post.find(@posts[2]),
        Post.find(@posts[1]),
        Post.find(@posts[0])
      ]
      should assign_to(:posts).with(expected)
    }
  end

  context "#show" do
    let(:post) { FactoryGirl.create(:post, space: space) }
    before { get :show, id: post.to_param, space_id: space.to_param }

    skip { should_authorize an_instance_of(Post), :show, id: post.to_param, space_id: space.to_param }

    it { should render_template('show') }
    it { should render_with_layout('spaces_show') }
    it { should assign_to(:space).with(space) }
    it { should assign_to(:post).with(post) }
  end

  context "#new" do
    before {
      space.add_member!(user)
      sign_in(user)
    }

    skip { should_authorize an_instance_of(Post), :new, space_id: space.to_param }

    context "normal browser request" do
      before { get :new, space_id: space.to_param }

      it { should render_template('new') }
      it { should render_with_layout('spaces_show') }
      it { should assign_to(:space).with(space) }
      it { should assign_to(:post).with(an_instance_of(Post)) }
    end

    context "xhr request" do
      before { xhr :get, :new, space_id: space.to_param }

      it { should render_template('new') }
      it { should_not render_with_layout }
    end
  end

  context "#create" do
    before {
      sign_in(user)
      space.add_member!(user)
    }

    skip { should_authorize an_instance_of(Post), :create, via: :post, space_id: space.to_param, post: {} }

    context "with valid parameters" do
      let(:post_attributes) { FactoryGirl.attributes_for(:post) }
      let(:params) {
        {
          space_id: space.to_param, post: post_attributes,
          controller: "posts", action: "create"
        }
      }

      let(:post_allowed_params) { [:title, :text, :parent_id] }
      before {
        post_attributes.stub(:permit).and_return(post_attributes)
        controller.stub(:params).and_return(params)

        expect {
          put :create, space_id: space.to_param, post: post_attributes
        }.to change { space.posts.count }.by(1) && change { RecentActivity.count }.by(1)
      }
      it { post_attributes.should have_received(:permit).with(*post_allowed_params) }
      it { should redirect_to(space_posts_path(space)) }
      it { should set_flash.to(I18n.t("flash.posts.create.notice")) }
      it { Post.last.author.should eq(user) }
    end

    it "with invalid parameters"
  end

  context "#edit" do
    let(:post) { FactoryGirl.create(:post, space: space) }
    let(:user) { post.author }

    before {
      sign_in(user)
      space.add_member!(user)
    }

    skip { should_authorize an_instance_of(Post), :edit, space_id: space.to_param, id: post.to_param }

    context "normal browser request" do
      before { get :edit, id: post.to_param, space_id: space.to_param }

      it { should render_template('edit') }
      it { should render_with_layout('spaces_show') }
      it { should assign_to(:space).with(space) }
      it { should assign_to(:post).with(post) }
    end

    context "xhr request" do
      before { xhr :get, :edit, id: post.to_param, space_id: space.to_param }

      it { should render_template('edit') }
      it { should_not render_with_layout }
    end
  end

  describe "#update" do
    let!(:post) { FactoryGirl.create(:post, space: space) }
    let(:user) { post.author }
    before do
      space.add_member!(user)
      sign_in(user)
    end

    skip { should_authorize an_instance_of(Post), :update, via: :put, id: post.id, space_id: space.to_param, :post => {} }

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
      it { should set_flash.to(I18n.t("flash.posts.update.notice")) }
    end

    context "changing no parameters" do
      before(:each) {
        expect {
          put :update, id: post.to_param, space_id: space.to_param, :post => {}
        }.not_to change { RecentActivity.count }
      }

      it { should redirect_to(space_posts_path(space)) }
      it { should set_flash.to(I18n.t("flash.posts.update.notice")) }
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
      it { should set_flash.to(I18n.t("flash.posts.update.notice")) }
    end
  end

  context "#destroy" do
    let(:post) { FactoryGirl.create(:post, space: space) }
    skip { should_authorize an_instance_of(Post), :destroy, via: :delete, id: post.to_param, space_id: space.to_param }

    before {
      sign_in(user)
      space.add_member!(user)

      delete :destroy, id: post.param, space_id: space.to_param
    }

    it 'changes the count by -1'
    it 'deletes the replies to the post'
    it 'blocks non registered users from deleting'
  end

  context "#reply_post" do
    let(:post) { FactoryGirl.create(:post, space: space) }
    skip { should_authorize an_instance_of(Post), :reply_post, via: :post, id: post.to_param, space_id: space.to_param }

    it 'changes the count by +1'
    it 'references the right replied to post'
    it 'doesnt create with invalid parameters'
  end

  describe "abilities", :abilities => true do
    it "abilities"
  end
end
