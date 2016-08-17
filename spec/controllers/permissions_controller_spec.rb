# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe PermissionsController do

  describe "#update" do
    let!(:new_role) { Role.where(:name => 'Admin').first }
    let(:permission) { FactoryGirl.create(:space_permission) }
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { permission.subject }

    context "update permissions" do
      before(:each) {
        request.env['HTTP_REFERER'] = space_path(space)
        space.add_member!(user, 'Admin')
        sign_in(user)
      }

      context "with valid attributes" do
        before(:each) {
          put :update, :id => permission.id, :permission => { :role_id => new_role.id }
        }

        it { should redirect_to space_path(space) }
        it { should set_flash.to(I18n.t('permission.update.success')) }
        it { permission.reload.role.should eq(new_role) }
      end

      context "with inexistent role in attributes" do
        before(:each) {
          put :update, :id => permission.id, :permission => { :role_id => Role.count + 1 }
        }

        it { should redirect_to space_path(space) }
        it { should set_flash.to(I18n.t('permission.update.failure')) }
        it { permission.reload.role.should_not eq(new_role) }
      end

    end
  end

  it "#destroy"
end
