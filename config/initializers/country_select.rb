Rails.application.config.to_prepare do
  # CountrySelect::FORMATS[:with_alpha3] = lambda do |country|
  #   loc = case I18n.locale.to_s
  #         when 'pt-br' then 'pt'
  #         when 'es-419' then 'es'
  #         else I18n.locale.to_s
  #         end
  #   "#{country.translations[loc] || country.name} (#{country.alpha3})"
  # end

  ISO3166.configure do |config|
    config.locales = Rails.application.config.available_locales_countries
  end
end
