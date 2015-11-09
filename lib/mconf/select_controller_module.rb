module Mconf
  module SelectControllerModule

    def select
      # try to get already set collection (@spaces) or use the class name for a query (Space)
      collection = instance_variable_get("@#{controller_name}") || controller_name.classify.constantize

      terms = params[:q].try(:split, /\s+/)
      id = params[:i] # select by id
      limit = params[:limit] || 5   # default to 5
      limit = 50 if limit.to_i > 50 # no more than 50

      result = if id
        collection.find_by_id(id)
      elsif collection.nil?
        collection.limit(limit)
      else
        collection.search_by_terms(terms).limit(limit)
      end

      instance_variable_set("@#{controller_name}", result)
    end

  end
end