# Taken from http://www.eq8.eu/blogs/1-shoulda-matchers-depricated-now-what
RSpec::Matchers.define :respond_with_content_type do |ability|
  match do |controller|
    expected_as_array.each do |format|
      controller.response.content_type.to_s.should eq Mime::Type.lookup_by_extension(format.to_sym).to_s
    end
  end

  failure_message_for_should do |actual|
    "expected response with content type #{actual.to_sym}"
  end

  failure_message_for_should_not do |actual|
    "expected response not to be with content type #{actual.to_sym}"
  end
end
