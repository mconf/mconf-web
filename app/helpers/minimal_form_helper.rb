require "minimal_form_builder"
module MinimalFormHelper
  def minimal_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(:builder => MinimalFormBuilder)), &block)
  end

  def minimal_fields_for(*args, &block)
    options = args.extract_options!
    simple_fields_for(*(args << options.merge(:builder => MinimalFormBuilder)), &block)
  end
end