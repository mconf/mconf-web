# Require Station Model
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/models/singular_agent"

class SingularAgent
  def superuser
    false
  end
  alias superuser? superuser

  def profile
    nil
  end

  def email
    ""
  end

  def <=>(agent)
    self.name <=> agent.name
  end

  def disabled
    false
  end

  def active?
    true
  end

  def expanded_post
    false
  end
end
