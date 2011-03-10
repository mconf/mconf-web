require "spec_helper"

describe Attachment do
=begin
  fixtures :users, :spaces

  TEST_FILE_NAME = "grid.png"
  TEST_FILE_PATH = "#{ Rails.root.to_s }/public/images/#{ TEST_FILE_NAME }"
  TEST_CONTENT_TYPE = "image/png"

  it "should create a new instance given valid attributes" do
    media_file = Tempfile.new("media")

    a = Attachment.new(:media => ActionController::TestUploadedFile.new(TEST_FILE_PATH, TEST_CONTENT_TYPE))
    a.author = users(:user_normal)
    a.container = spaces(:private_admin)

    assert_valid a
  end
=end
end
