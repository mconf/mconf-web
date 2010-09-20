# Monkey patch for showing default locale translations when missing in current locale

class I18n::Backend::Simple

  def translate(locale, key, options = {})
    raise InvalidLocale.new(locale) if locale.nil?
    return key.map { |k| translate(locale, k, options) } if key.is_a? Array

    reserved = :scope, :default
    count, scope, default = options.values_at(:count, *reserved)
    options.delete(:default)
    values = options.reject { |name, value| reserved.include?(name) }

    entry = lookup(locale, key, scope)
    if entry.nil?
      entry = lookup(I18n.default_locale, key, scope)
    end
    if entry.nil?
      entry = default(locale, default, options)
      if entry.nil?
        raise(I18n::MissingTranslationData.new(locale, key, options))
      end
    end
    entry = pluralize(locale, entry, count)
    entry = interpolate(locale, entry, values)
    entry
  end
end
