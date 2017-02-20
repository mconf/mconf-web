class AttributeRole < ActiveRecord::Base
  belongs_to :role

  def self.find_by_role_name name
    r = Role.where(name: name).first

    where(role: r).first
  end

  def role_name
    role.try(:name)
  end
end
