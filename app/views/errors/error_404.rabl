object false

node :errors do
  {
    :message => @error_message.nil? ? t("error.e404.description", :url => @route) : @error_message,
    :code => 404
  }
end