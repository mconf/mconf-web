class Forgery::Name < Forgery

  def self.unique_full_name(n)
    "#{self.full_name} #{n}"
  end

  # Unique names for events
  def self.unique_event_name(n)
    "#{self.company_name} #{n}"
  end

  # Unique names for spaces
  def self.unique_space_name(n)
    unique_event_name(n)
  end
end
