# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Profile do
  before(:each) do

    #a private space and two users in that space
    @private_space = Factory(:private_space)
    @admin = Factory(:admin_performance, :stage => @private_space).agent
    @user = Factory(:user_performance, :stage => @private_space).agent
    #a public space and two users in that space
    @public_space = Factory(:public_space)
    @user_public_1 = Factory(:user_performance, :stage => @public_space).agent
    @user_public_2 = Factory(:user_performance, :stage => @public_space).agent

  end

  it "should create a new instance given valid attributes" do
    @valid_attributes = { :phone => "673548798",
                          :city => "Madrid",
                          :country => "Spain",
                          :organization => "Dit"}
    Profile.create!(@valid_attributes)
  end

  it "should authorize its own user with visibility :everybody" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :everybody and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
    (@user.profile.authorize? :read, :to => @user).should be_true

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it "should authorize its own user with visibility :members" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :members and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:members))
    (@user.profile.authorize? :read, :to => @user).should be_true

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it "should authorize its own user with visibility :public_fellows" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :public_fellows and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    (@user.profile.authorize? :read, :to => @user).should be_true

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it "should authorize its own user with visibility :private_fellows" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :private_fellows and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
    (@user.profile.authorize? :read, :to => @user).should be_true

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it "should authorize its own user with visibility :nobody" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :nobody and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
    (@user.profile.authorize? :read, :to => @user).should be_true

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it "should authorize a NOT logged user (not the owner of the profile) with visibility :everybody" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :everybody and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
    (@user.profile.authorize? :read, :to => nil).should be_true

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it "should NOT authorize a NOT logged user (not the owner of the profile) with visibility :members" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :members and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:members))
    (@user.profile.authorize? :read, :to => nil).should be_false

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it "should authorize a logged user (not the owner of the profile) with visibility :members" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :members and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:members))
    (@user.profile.authorize? :read, :to => @user_public_1).should be_true

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it ("should NOT authorize a logged user (not the owner of the profile) with visibility :public_fellows " +
    "if that user is NOT in the same public or private space as the owner of the profile") do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :public_fellows and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    (@user.profile.authorize? :read, :to => @user_public_1).should be_false

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it ("should authorize a logged user (not the owner of the profile) with visibility :public_fellows " +
    "if that user is in the same public or private space as the owner of the profile") do
    #first we fill the user profile
    @user_public_2.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :public_fellows and check the authorization
    @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    (@user_public_2.profile.authorize? :read, :to => @user_public_1).should be_true

    #we restore the visibility to the default value
    @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it ("should NOT authorize a logged user (not the owner of the profile) with visibility :private_fellows " +
    "if that user is NOT in the same PRIVATE space as the owner of the profile") do
    #first we fill the user profile
    @user_public_2.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :private_fellows and check the authorization
    @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
    (@user_public_2.profile.authorize? :read, :to => @user_public_1).should be_false

    #we restore the visibility to the default value
    @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it ("should authorize a logged user (not the owner of the profile) with visibility :private_fellows " +
    "if that user is in the same PRIVATE space as the owner of the profile") do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :private_fellows and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
    (@user.profile.authorize? :read, :to => @admin).should be_true

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  it "should NOT authorize a logged user (not the owner of the profile) with visibility :nobody" do
    #first we fill the user profile
    @user.profile.update_attributes FactoryGirl.attributes_for(:profile)

    #we set the visibility to :nobody and check the authorization
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
    (@user.profile.authorize? :read, :to => @admin).should be_false

    #we restore the visibility to the default value
    @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
  end

  after(:each) do

    @private_space.destroy
    @admin.destroy
    @user.destroy
    @public_space.destroy
    @user_public_1.destroy
    @user_public_2.destroy

  end

end
