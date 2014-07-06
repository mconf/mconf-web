# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe AttachmentsController do
  render_views

  describe "can't access if document repository is false" do
    let(:space) { FactoryGirl.create(:space, :repository => false) }
    let(:user) { FactoryGirl.create(:superuser) }
    let(:attachment) { FactoryGirl.create(:attachment, :space => space) }
    before(:each) { sign_in(user) }

    context "index" do
      before(:each) {
        controller.should_not_receive(:index)
        get :index, :space_id => space.to_param
      }
      it { should redirect_to space_path(space) }
      it { should set_the_flash.to(I18n.t('attachment.repository_disabled')) }
    end

    context "show" do
      before(:each) { get :show, :id => attachment.id, :space_id => space.to_param }
      it { should redirect_to space_path(space) }
      it { should set_the_flash.to(I18n.t('attachment.repository_disabled')) }
    end

    context "new" do
      before(:each) { get :new, :space_id => space.to_param }
      it { should redirect_to space_path(space) }
      it { should set_the_flash.to(I18n.t('attachment.repository_disabled')) }
    end

    context "create" do
      before(:each) { post :create, :space_id => space.to_param }
      it { should redirect_to space_path(space) }
      it { should set_the_flash.to(I18n.t('attachment.repository_disabled')) }
    end

    context "destroy" do
      before(:each) { delete :destroy, :id => attachment.id, :space_id => space.to_param }
      it { should redirect_to space_path(space) }
      it { should set_the_flash.to(I18n.t('attachment.repository_disabled')) }
    end

    context "delete_collection" do
      before(:each) { delete :delete_collection, :space_id => space.to_param }
      it { should redirect_to space_path(space) }
      it { should set_the_flash.to(I18n.t('attachment.repository_disabled')) }
    end
  end

  describe "#index" do
    let(:space) { FactoryGirl.create(:space, :repository => true) }
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

    describe "params"
    describe "order"
  end

  describe "#index.zip"

  describe "#show" do
    let(:space) { FactoryGirl.create(:space, :repository => true) }
    let(:attachment) { FactoryGirl.create(:attachment, :space => space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    before { controller.stub(:render) }
    it {
      controller.should_receive(:send_file).with(attachment.full_filename)
      get :show, :id => attachment.id, :space_id => space.to_param
    }
  end

  describe "#new" do
    let(:space) { FactoryGirl.create(:space, :repository => true) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "normal request" do
      before(:each) { get :new, :space_id => space.to_param }

      context "template and layout" do
        it { should render_template('new') }
        it { should render_with_layout('spaces_show') }
      end

      it { assigns(:space).should eq(space) }
      it { assigns(:attachment).should be_instance_of(Attachment) }
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
    let(:space) { FactoryGirl.create(:space, :repository => true) }
    before(:each) {
      request.env['HTTP_REFERER'] = '/'
      sign_in(user)
    }

    context "with valid attributes" do
      let(:attributes) { FactoryGirl.attributes_for(:attachment) }

      describe "creates the attachment with correct attributes" do
        before(:each) {
          expect {
            post :create, :space_id => space.to_param, :attachment => attributes
          }.to change(space.attachments, :count).by(1)
        }

        it { should redirect_to space_attachments_path(space) }
      end
    end

    context "with invalid attributes"
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:superuser) }
    let(:attachment) { FactoryGirl.create(:attachment) }
    let(:space) { attachment.space }
    before(:each) { sign_in(user) }

    context "destroy attachment" do
      before(:each) {
        expect {
          delete :destroy, :id => attachment.id, :space_id => space.to_param
        }.to change(space.attachments, :count).by(-1)
      }

      it { should redirect_to space_attachments_path }
    end
  end

  describe "#destroy_collection" do
    let(:user) { FactoryGirl.create(:superuser) }
    let(:space) { FactoryGirl.create(:space, :repository => true) }
    let(:attachments) {
      [FactoryGirl.create(:attachment, :space => space),
       FactoryGirl.create(:attachment, :space => space)]
    }
    let(:params) {
      {:attachment_ids => "#{attachments[0].id},#{attachments[1].id}",
      :space_id => space.to_param}
    }
    before(:each) {
      attachments
      sign_in(user)
    }

    context "destroy attachments" do
      before(:each) {
        expect {
          delete :delete_collection, params
        }.to change(space.attachments, :count).by(-2)
      }

      it { should redirect_to space_attachments_path }
    end
  end
end
