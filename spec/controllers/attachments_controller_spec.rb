# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
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
    let(:superuser) { FactoryGirl.create(:superuser) }
    let(:user) { FactoryGirl.create(:user) }

    describe "orders the attachments properly"

    context "in a public space" do
      let(:space) { FactoryGirl.create(:space_with_associations, repository: true, public: true) }

      context "logged in" do
        context "as a superuser" do
          before(:each) {
            sign_in(superuser)
            get :index, :space_id => space.to_param
          }

          context "template and layout" do
            it { should render_template('index') }
            it { should render_with_layout('spaces_show') }
          end

          it { assigns(:space).should eq(space) }
        end

        context "as a normal user that is in the space" do
          before {
            space.add_member!(user)
            sign_in(user)
            get :index, space_id: space.to_param
          }

          context "template and layout" do
            it { should render_template('index') }
            it { should render_with_layout('spaces_show') }
          end

          it { assigns(:space).should eq(space) }
        end


        context "as a normal user that is not in the space" do
          before {
            space.add_member!(user)
            sign_in(user)
            get :index, space_id: space.to_param
          }

          context "template and layout" do
            it { should render_template('index') }
            it { should render_with_layout('spaces_show') }
          end

          it { assigns(:space).should eq(space) }
        end
      end

      context "as an anonymous user" do
        before { get :index, space_id: space.to_param }
        it { should render_template('index') }
        it { should render_with_layout('spaces_show') }
      end
    end

    context "in a private space" do
      let(:space) { FactoryGirl.create(:space_with_associations, repository: true, public: false) }

      context "logged in" do
        context "as a superuser" do
          before(:each) {
            sign_in(superuser)
            get :index, :space_id => space.to_param
          }

          context "template and layout" do
            it { should render_template('index') }
            it { should render_with_layout('spaces_show') }
          end

          it { assigns(:space).should eq(space) }
        end

        context "as a normal user that is in the space" do
          before {
            space.add_member!(user)
            sign_in(user)
            get :index, space_id: space.to_param
          }

          context "template and layout" do
            it { should render_template('index') }
            it { should render_with_layout('spaces_show') }
          end

          it { assigns(:space).should eq(space) }
        end

        context "as a normal user that is not in the space" do
          before {
            sign_in(user)
          }
          it {
            expect {
              get :index, space_id: space.to_param
            }.to raise_error(CanCan::AccessDenied)
          }
        end
      end

      context "as an anonymous user" do
        before { get :index, space_id: space.to_param }
        it { should redirect_to login_url }
      end
    end

  end

  describe "#index.zip"

  describe "#show" do
    let(:attachment) { FactoryGirl.create(:attachment, :space => space) }
    let(:superuser) { FactoryGirl.create(:superuser) }
    let(:user) { FactoryGirl.create(:user) }

    context "in a public space" do
      let(:space) { FactoryGirl.create(:space, repository: true, public: true) }

      context "logged in" do
        context "as a superuser" do
          before(:each) { sign_in(superuser) }

          before { controller.stub(:render) }
          it {
            controller.should_receive(:send_file).with(attachment.full_filename)
            get :show, :id => attachment.id, :space_id => space.to_param
          }
        end

        context "as a normal user that is in the space" do
          before(:each) {
            space.add_member!(user)
            sign_in(user)
          }

          before { controller.stub(:render) }
          it {
            controller.should_receive(:send_file).with(attachment.full_filename)
            get :show, :id => attachment.id, :space_id => space.to_param
          }
        end
      end

      context "as an anonymous user" do
        before { controller.stub(:render) }
        it {
          controller.should_receive(:send_file).with(attachment.full_filename)
          get :show, :id => attachment.id, :space_id => space.to_param
        }
      end
    end

    context "in a private space" do
      let(:space) { FactoryGirl.create(:space, repository: true, public: false) }

      context "logged in" do
        context "as a superuser" do
          before(:each) { sign_in(superuser) }

          before { controller.stub(:render) }
          it {
            controller.should_receive(:send_file).with(attachment.full_filename)
            get :show, :id => attachment.id, :space_id => space.to_param
          }
        end

        context "as a normal user that is in the space" do
          before(:each) {
            space.add_member!(user)
            sign_in(user)
          }

          before { controller.stub(:render) }
          it {
            controller.should_receive(:send_file).with(attachment.full_filename)
            get :show, :id => attachment.id, :space_id => space.to_param
          }
        end
      end

      context "as an anonymous user" do
        before { get :show, id: attachment.id, space_id: space.to_param }
        it { should redirect_to login_path }
      end
    end

  end

  describe "#new" do
    let(:space) { FactoryGirl.create(:space, :repository => true) }
    let(:user) { FactoryGirl.create(:user) }
    before {
      space.add_member!(user)
    }

    context "as a logged in user" do
      before {
        sign_in(user)
        xhr :get, :new, :space_id => space.to_param
      }

      context "template and layout" do
        it { should render_template('new') }
        it { should_not render_with_layout }
      end
    end

    context "as an anonymous user" do
      before { xhr :get, :new, space_id: space.to_param }
      it { should respond_with(:unauthorized) }
    end
  end

  describe "#create" do
    let(:user) { FactoryGirl.create(:superuser) }
    let(:space) { FactoryGirl.create(:space, :repository => true) }

    context "as a logged in user" do
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

          context "it creates a new recent activity" do
            it { RecentActivity.last.trackable.should eq(Attachment.last) }
            it { RecentActivity.last.owner.should eq(Attachment.last.space) }
            it { RecentActivity.last.key.should eq('attachment.create') }
          end
        end
      end

      context "with valid attributes but repeated file name" do
        let!(:file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test-logo.png'))) }
        let!(:attachment) { FactoryGirl.create(:attachment, :space => space, :attachment => file) }

        before(:each) {
          expect {
            post :create, :space_id => space.to_param, :uploaded_file => file
          }.to change(space.attachments, :count).by(1)
        }

        it { should redirect_to space_attachments_path(space) }
        it { Attachment.last.title.should_not eq(attachment.title) }
        it { Attachment.last.title.should eq('test-logo_1.png') }
      end

      context "with valid attributes but repeated file name (of a file in another space)" do
        let(:space2) { FactoryGirl.create(:space) }
        let!(:file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test-logo.png'))) }
        let!(:attachment) { FactoryGirl.create(:attachment, :space => space2, :attachment => file) }

        before(:each) {
          expect {
            post :create, :space_id => space.to_param, :uploaded_file => file
          }.to change(space.attachments, :count).by(1)
        }

        it { should redirect_to space_attachments_path(space) }
        it { Attachment.last.title.should eq(attachment.title) }
        it { Attachment.last.title.should_not eq('test-logo_1.png') }
      end

      context "with invalid attributes"
    end

    context "as an anonymous user" do
      let(:attributes) { FactoryGirl.attributes_for(:attachment) }
      before { post :create, space_id: space.to_param, attachment: attributes }
      it { should respond_with(:redirect) }
      it { should redirect_to new_user_session_path }
    end
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:superuser) }
    let(:attachment) { FactoryGirl.create(:attachment_with_associations) }
    let(:space) { attachment.space }

    context "as a logged in user" do
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

    context "as an anonymous user" do
      before { delete :destroy, id: attachment.id, space_id: space.to_param }
      it { should respond_with(:redirect) }
      it { should redirect_to new_user_session_path }
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

    context "as a logged in user" do
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

    context "as an anonymous user" do
      before { delete :delete_collection, params }
      it { should redirect_to 'http://test.host/users/login' }
    end
  end
end
