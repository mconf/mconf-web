class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates_presence_of :action

  def title
    objective ?
      I18n.t(action, :scope => objective.underscore, :count => :other) :
      I18n.t(action)
  end

  def <=>(other)
    title <=> other.title
  end

  def to_array
    [action, objective].compact.map(&:to_sym)
  end
end
