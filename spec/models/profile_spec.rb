# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Profile do

  it { should respond_to(:logo_image) }
  it { should respond_to(:crop_x) }
  it { should respond_to(:"crop_x=") }
  it { should respond_to(:crop_y) }
  it { should respond_to(:"crop_y=") }
  it { should respond_to(:crop_w) }
  it { should respond_to(:"crop_w=") }
  it { should respond_to(:crop_h) }
  it { should respond_to(:"crop_h=") }
  it { should respond_to(:crop_img_w) }
  it { should respond_to(:"crop_img_w=") }
  it { should respond_to(:crop_img_h) }
  it { should respond_to(:"crop_img_h=") }

  describe "#correct_url" do
    let(:profile) { FactoryGirl.create(:profile) }
    shared_examples_for "url has been corrected" do
      it { profile.reload.url.should eq(final_url) }
      it { profile.reload.should be_valid }
      it { profile.reload.should be_persisted }
    end

    before { profile.update_attributes(:url => url) }

    context "an url without http://" do
      let(:url) { 'mysite.com/dsbang' }
      let(:final_url) { 'http://mysite.com/dsbang' }
      it_should_behave_like 'url has been corrected'
    end

    context "a nil url" do
      let(:url) { nil }
      let(:final_url) { nil }
      it_should_behave_like 'url has been corrected'
    end

    context "an url with http" do
      let(:url) { 'httpmysite.com/dsbang' }
      let(:final_url) { 'http://httpmysite.com/dsbang' }
      it_should_behave_like 'url has been corrected'
    end

    context "an url with http://" do
      let(:url) { 'http://mysite.com/dsbang' }
      let(:final_url) { url }
      it_should_behave_like 'url has been corrected'
    end

  end

  describe "#from_vcard" do
    let(:old_email) { 'old@email.com' }
    let(:profile) { FactoryGirl.create(:user, email: old_email).profile }

    before { profile.update_attributes(vcard: vcard_file) }

    context 'on success' do
      let(:vcard_file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, './spec/fixtures/files/example.vcf'))) }

      it { profile.should be_persisted }
      it { profile.full_name.should eq('Mikael Stanne') }
      it { profile.organization.should eq('Dark Tranquillity') }
      it { profile.user.email.should eq(old_email) }
    end

    context 'on corrupt vcard file' do
      let(:vcard_file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, './spec/fixtures/files/invalid.vcf'))) }

      it { profile.errors[:vcard].size.should eq(1) }
      it { profile.full_name.should_not eq('Mikael Stanne') }
      it { profile.organization.should_not eq('Dark Tranquillity') }
    end

    context 'on blank vcard file' do
      let(:vcard_file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, './spec/fixtures/files/invalid2.vcf'))) }

      it { profile.errors[:vcard].size.should eq(1) }
    end

  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:update_logo, :update_full_name])
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:user).profile }

    # commons specs run for several types of users
    shared_examples_for "a profile's ability" do |visibilities|
      context "given the profile visibility is" do
        visibilities.each do |visibility|
          it "'#{visibility}'" do
            target.visibility = Profile::VISIBILITY.index(visibility)
            should_not be_able_to_do_anything_to(target).except([:index, :show])
          end
        end
        Profile::VISIBILITY.each do |visibility|
          unless visibilities.include?(visibility)
            it "'#{visibility}'" do
              target.visibility = Profile::VISIBILITY.index(visibility)
              should_not be_able_to_do_anything_to(target).except(:index)
            end
          end
        end
      end
    end

    context "when is the profile owner" do
      let(:user) { target.user }
      context "regardless of the profile's visibility" do
        Profile::VISIBILITY.each do |visibility|
          before { target.visibility = Profile::VISIBILITY.index(visibility) }
          it { should be_able_to(:show, target) }
          it { should be_able_to(:update, target) }
          it { should be_able_to(:update_logo, target) }
        end
      end

      context "if the target user is disabled" do
        before { target.user.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "cannot edit the full name if the account was created by shib" do
        before {
          Site.current.update_attributes(shib_update_users: true)
          FactoryGirl.create(:shib_token, user: target.user, new_account: true)
        }
        it { should_not be_able_to(:update_full_name, target) }
      end

      context "can edit the full name if the account was not created by shib" do
        before {
          Site.current.update_attributes(shib_update_users: true)
          FactoryGirl.create(:shib_token, user: target.user, new_account: false)
        }
        it { should be_able_to(:update_full_name, target) }
      end

      context "can edit the full name if the site is not updating user information automatically" do
        before {
          Site.current.update_attributes(shib_update_users: false)
          FactoryGirl.create(:shib_token, user: target.user, new_account: true)
        }
        it { should be_able_to(:update_full_name, target) }
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      context "regardless of the profile's visibility" do
        Profile::VISIBILITY.each do |visibility|
          before { target.visibility = Profile::VISIBILITY.index(visibility) }
          it { should be_able_to_do_everything_to(target) }
        end
      end

      context "if the target user is disabled" do
        before { target.user.disable }
        it { should be_able_to_do_everything_to(target) }
      end
    end

    context "when is an anonymous user" do
      let(:user) { User.new }
      it_should_behave_like "a profile's ability", [:everybody]

      context "if the target user is disabled" do
        before { target.user.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a website member (but not a fellow)" do
      let(:user) { FactoryGirl.create(:user) }
      it_should_behave_like "a profile's ability", [:everybody, :members]

      context "if the target user is disabled" do
        before { target.user.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a public fellow user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:space) { FactoryGirl.create(:public_space) }
      before {
        space.add_member!(target.user)
        space.add_member!(user)
      }
      it_should_behave_like "a profile's ability",
        [:everybody, :members, :public_fellows]

      context "if the target user is disabled" do
        before { target.user.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a private fellow user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:space) { FactoryGirl.create(:private_space) }
      before {
        space.add_member!(target.user)
        space.add_member!(user)
      }
      it_should_behave_like "a profile's ability",
        [:everybody, :members, :public_fellows, :private_fellows]

      context "if the target user is disabled" do
        before { target.user.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end
  end

  context "after_update" do
    let(:user) { FactoryGirl.create(:user) }
    let(:profile) { user.profile }

    context "updates the name of the user's web conference room" do
      before(:each) {
        profile.user.bigbluebutton_room.update_attribute(:name, "name before")
        profile.update_attributes(:full_name => "name after")
      }

      it { profile.user.bigbluebutton_room.name.should eq("name after") }
    end
  end

end
