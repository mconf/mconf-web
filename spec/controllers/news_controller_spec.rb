# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe NewsController do
  render_views

  describe "#index" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) {
      sign_in(user)
      get :index, :space_id => space.to_param
    }

    context "template and layout" do
      it { should render_template('index') }
      it { should render_with_layout('spaces_show') }
    end

    it { assigns(:space).should eq(space) }
    it { assigns(:news).should be_new_record }
  end

  describe "#show" do
    let(:news) { FactoryGirl.create(:news) }
    let(:space) { news.space }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) {
      sign_in(user)
      get :show, :space_id => space.to_param, :id => news.id
    }

    context "template and layout" do
      it { should render_template('show') }
      it { should render_with_layout('application') }
    end

    it { assigns(:space).should eq(space) }
    it { assigns(:news).should eq(news) }
  end

  describe "#new" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "normal request" do
      before(:each) { get :new, :space_id => space.to_param }

      context "template and layout" do
        it { should render_template('new') }
        it { should render_with_layout('application') }
      end

      it { assigns(:space).should eq(space) }
      it { assigns(:news).should be_instance_of(News) }
    end

    context "xhr request" do
      before(:each) { xhr :get, :new, :space_id => space.to_param }

      context "template and layout" do
        it { should render_template('new') }
        it { should_not render_with_layout }
      end
    end
  end

  describe "#create" do
    let(:user) { FactoryGirl.create(:superuser) }
    let(:space) { FactoryGirl.create(:space) }
    before(:each) {
      request.env['HTTP_REFERER'] = '/'
      sign_in(user)
    }

    context "with valid attributes" do
      let(:attributes) { FactoryGirl.attributes_for(:news) }

      describe "creates the news with correct attributes" do
        before(:each) {
          expect {
            post :create, :space_id => space.to_param, :news => attributes
          }.to change(space.news, :count).by(1)
        }

        it { should redirect_to '/' }
      end
    end

    context "with invalid attributes"
  end

  describe "#update" do
    let(:user) { FactoryGirl.create(:superuser) }
    let(:news) { FactoryGirl.create(:news) }
    let(:space) { news.space }
    before(:each) { sign_in(user) }

    context "with valid attributes" do
      describe "updates the news correct attributes" do
        before(:each) {
          put :update, :id => news.id, :space_id => space.to_param, :news => { :title => 'New title' }
        }

        it { news.reload.title.should eq('New title') }
        it { should redirect_to space_news_index_path(space) }
      end
    end
  end

  describe "#edit" do
    let(:news) { FactoryGirl.create(:news) }
    let(:space) { news.space }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "normal request" do
      before(:each) { get :edit, :id => news.id, :space_id => space.to_param }

      context "template and layout" do
        it { should render_template('edit') }
        it { should render_with_layout('application') }
      end

      it { assigns(:space).should eq(space) }
      it { assigns(:news).should eq(news) }
    end

    context "xhr request" do
      before(:each) { xhr :get, :edit, :id => news.id, :space_id => space.to_param }

      context "template and layout" do
        it { should render_template('edit') }
        it { should_not render_with_layout }
      end
    end
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:superuser) }
    let(:news) { FactoryGirl.create(:news) }
    let(:space) { news.space }
    before(:each) {
      request.env['HTTP_REFERER'] = '/'
      sign_in(user)
    }

    context "destroy news" do
      before(:each) {
        expect {
          delete :destroy, :id => news.id, :space_id => space.to_param
        }.to change(space.news, :count).by(-1)
      }

      it { should redirect_to '/' }
    end
  end
end
