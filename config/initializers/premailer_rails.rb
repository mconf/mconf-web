options = {
  :preserve_styles => true,
  :remove_ids => true,
  :remove_comments => true
  #:generate_text_part => false,
}
Premailer::Rails.config.merge!(options)
