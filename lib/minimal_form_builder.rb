class MinimalFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, options = {}, &block)
    type = options.fetch(:as, nil) || default_input_type(
        attribute_name,
        find_attribute_column(attribute_name),
        options
    )

    if type != :boolean
      if options[:placeholder].nil?
        options[:placeholder] ||= if object.class.respond_to?(:human_attribute_name)
                                    object.class.human_attribute_name(attribute_name.to_s)
                                  else
                                    attribute_name.to_s.humanize
                                  end
      end
      options[:label] = false if options[:label].nil?
    end

    super
  end
end