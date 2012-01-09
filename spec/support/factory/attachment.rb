include ActionDispatch::TestProcess

Factory.class_eval do
  def attachment(name, path, content_type = nil)
    path_with_rails_root = File.join(PathHelpers.assets_full_path, path)
    uploaded_file = fixture_file_upload(path_with_rails_root, content_type)
    add_attribute name, uploaded_file
  end
end


