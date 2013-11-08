require 'spec_helper'

describe ManageController do

  describe "#users" do
    it "is successful"
    it "sets @users to a list of all users, including disabled users"
    it "orders @users by username"
    it "paginates the list of users"
    it "renders manage/users"
    it "renders with the layout no_sidebar"
  end

  describe "#spaces" do
    it "is successful"
    it "sets @spaces to a list of all spaces, including disabled spaces"
    it "orders @spaces by name"
    it "paginates the list of spaces"
    it "renders manage/spaces"
    it "renders with the layout application"
  end

  describe "#spam" do
    it "is successful"
    it "sets @spam_events to all events marked as spam"
    it "sets @spam_posts to all posts marked as spam"
    it "renders manage/spam"
    it "renders with the layout no_sidebar"
  end

end
