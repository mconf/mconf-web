# Agents play Roles in Containers
#
# Roles control permissions
class Role < ActiveRecord::Base
  include Comparable

  has_many :performances
  has_and_belongs_to_many :permissions
  has_many :invitations

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :stage_type

  acts_as_sortable :columns => [ :name, :stage_type ]

  named_scope :without_stage_type, lambda {
    { :conditions => [ "stage_type is NULL OR stage_type = ?", "" ] }
  }

  # Role comparison is based on the difference between Permissions
  def <=>(other)
    (permissions - other.permissions ).size - (other.permissions - permissions).size
  end
end
