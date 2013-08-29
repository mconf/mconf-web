# Put all your default configatron settings here.

# List of locales available in the application.
# We can't use `I18n.available_locales` because it returns all locales available including the
# ones included by gems, so if a gem has any locale the application doesn't it, would show up.
configatron.i18n.default_locales = [:en, :"pt-br"]

# Metadata keys Mconf-Web uses to store information in recordings
configatron.webconf.metadata.title = "mconfweb-title"
configatron.webconf.metadata.description = "mconfweb-description"
