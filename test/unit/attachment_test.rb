require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < ActiveSupport::TestCase
  TEST_FILE_NAME = "papelera.png"
  TEST_FILE_PATH = "#{ RAILS_ROOT }/public/images/#{ TEST_FILE_NAME }"
  TEST_CONTENT_TYPE = "image/png"
  
  # Replace this with your real tests.
  def test_valid_content
    media_file = Tempfile.new("media")

    a = Attachment.new(:media => ActionController::TestUploadedFile.new(TEST_FILE_PATH, TEST_CONTENT_TYPE))

    assert_valid a
  end

end
