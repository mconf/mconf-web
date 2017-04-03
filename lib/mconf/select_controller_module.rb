module Mconf
  module SelectControllerModule

    def select
      # try to get already set collection (@spaces) or use the class name for a query (Space)
      klass = if controller_name == "tags"
        ActsAsTaggableOn::Tag
      else
        controller_name.classify.constantize
      end
      collection = instance_variable_get("@#{controller_name}") || klass

      terms = params[:q].try(:split, /\s+/)
      id = params[:i] # select by id
      limit = params[:limit] || 5   # default to 5
      limit = 50 if limit.to_i > 50 # no more than 50

      result = if id
        collection.find_by_id(id)
      elsif collection.nil?
        collection.limit(limit)
      else
        collection.search_by_terms(terms, can?(:manage, klass))
          .search_order.limit(limit)
      end

      instance_variable_set("@#{controller_name}", result)
    end

  end
end
