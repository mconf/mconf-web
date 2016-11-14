# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

Rails.application.config.to_prepare do

  # Monkey-patches to add support for guest users in bigbluebutton_rails.
  # TODO: This is not standard in BBB yet, so this should be temporary and might
  #       be moved to bigbluebutton_rails in the future.

  ActsAsTaggableOn::Tag.instance_eval do
    # Copy of the default Bigbluebutton#join_url with support to :guest
    def search_by_terms(words, format)
      scope :search_by_terms, -> (words, include_private=false) {
      query = ActsAsTaggableOn::Tag

      words ||= []
      words = [words] unless words.is_a?(Array)
      query_strs = []
      query_params = []

      words.each do |word|
        str  = "name LIKE ?"
        query_strs << str
        query_params += ["%#{word}%"]
      end

      query.where(query_strs.join(' OR '), *query_params.flatten)
      }
    end
  end
end
