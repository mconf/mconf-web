# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

Rails.application.config.to_prepare do

  ActsAsTaggableOn::Tag.instance_eval do
    scope :search_by_terms, -> (words, include_private=false) {
      query = ActsAsTaggableOn::Tag

      words ||= []
      words = [words] unless words.is_a?(Array)
      query_strs = []
      query_params = []

      words.reject(&:blank?).each do |word|
        str  = "name LIKE ?"
        query_strs << str
        query_params += ["%#{word}%"]
      end

      query.where(query_strs.join(' OR '), *query_params.flatten)
    }

    scope :search_order, -> {
      order("name")
    }

    ActsAsTaggableOn.remove_unused_tags = true
    ActsAsTaggableOn.force_lowercase = true
    ActsAsTaggableOn.delimiter = ','
  end
end
