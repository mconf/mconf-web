class <%= class_name %> < ActiveRecord::Base
  acts_as_agent :activation => <%= options[:include_activation] %>
  acts_as_container
end
