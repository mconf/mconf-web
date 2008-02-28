# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def base_language_only
    yield if Locale.base?
  end

  def not_base_language
    yield unless Locale.base?
  end
end
