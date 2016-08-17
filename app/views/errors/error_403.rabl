object false

node :errors do
  {
    :message => @error_message.nil? ? t("error.e403.description") : @error_message,
    :code => 403
  }
end