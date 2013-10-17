# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe News do

  describe "abilities", :abilities => true do
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:news) }

    context "when is an anonymous user" do
      let(:user) { User.new }

      context "in a public space" do
        before { target.space.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except(:show) }
      end

      context "in a private space" do
        before { target.space.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a registered user" do
      let(:user) { FactoryGirl.create(:user) }

      context "in a public space" do
        before { target.space.update_attributes(:public => true) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except(:show) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.space.add_member!(user, "Admin") }
            it { should be_able_to(:manage, target) }
          end

          context "with the role 'User'" do
            before { target.space.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except(:show) }
          end
        end
      end

      context "in a private space" do
        before { target.space.update_attributes(:public => false) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.space.add_member!(user, "Admin") }
            it { should be_able_to(:manage, target) }
          end

          context "with the role 'User'" do
            before { target.space.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except(:show) }
          end
        end
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }

      context "in a public space" do
        before { target.space.update_attributes(:public => true) }
        it { should be_able_to(:manage, target) }
      end

      context "in a private space" do
        before { target.space.update_attributes(:public => false) }
        it { should be_able_to(:manage, target) }
      end
    end
  end

end
