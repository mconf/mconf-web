module Mconf
  class Routes

    # Returns all words already used for routes inside the `scope` (e.g. "/users").
    # if `scope` is nil, returns all words used in the root namespace.
    def self.reserved_names(scope=nil)
      scope = nil if scope.try(:strip) == '/'
      regexp = /\A#{scope}\/[^\/(:]*/
      Rails.application.routes.routes.map do |r|
        full_path = r.path.spec.to_s
        full_path.match(regexp).to_s.gsub(/\A.*\//, '')
      end.reject(&:blank?).uniq
    end

  end
end
