# Performance define the Role some Actor is playing in some Stage
#
# == Named scopes
#
# stage_type(type): find Peformances by Stage type
#
# == Only one with highest Role
# When there is only one Performance in some stage with the highest Role, the callbacks :avoid_downgrading_only_one_with_highest_role and :avoid_destroying_only_one_with_highest_role prevents the Stage runs out of Agents performing the highest Role. 
#
# E.g., in a Space, the only Administrator can't change his Role to a lower one and can't leave the Space without assigning a new Administrator

class Performance < ActiveRecord::Base
  belongs_to :agent, :polymorphic => true
  belongs_to :stage, :polymorphic => true
  belongs_to :role

  acts_as_sortable :columns => [ { :content => :agent,
                                   :sortable => false },
                                 { :name => :role,
                                   :render => 'edit_role_form',
                                   :sortable => true }
                               ]

  named_scope :stage_type, lambda { |type|
    type ?
      { :conditions => [ "stage_type = ?", type.to_s.classify ] } :
      {}
  }

  validates_presence_of :agent_id, :agent_type, :stage_id, :stage_type, :role_id
  validates_uniqueness_of :agent_id, :scope => [ :agent_type, :stage_id, :stage_type ]
  validates_uniqueness_of :agent_type, :scope => [ :agent_id, :stage_id, :stage_type ]

  # Avoid a Stage running from Performances with the most important Role
  validate_on_update :avoid_downgrading_only_one_with_highest_role
  before_destroy :avoid_destroying_only_one_with_highest_role

  authorization_delegate(:stage)

  private

  # Avoids the only Admin to change his role to a lower one
  def avoid_downgrading_only_one_with_highest_role
    if role_id_changed? &&
       role_id_was == stage.class.roles.sort.last.id &&
       Performance.find_all_by_stage_id_and_stage_type_and_role_id(stage.id, stage.class.base_class.to_s, role_id_was).size < 2

      errors.add(:role_id, I18n.t('performance.errors.stage_should_not_run_out_of_performances_with_first_role',
                             :role => stage.class.roles.sort.last.name))
    end
  end

  # Avoids the only Admin to leave the Stage
  def avoid_destroying_only_one_with_highest_role
    if role == stage.class.roles.sort.last &&
       Performance.find_all_by_stage_id_and_stage_type_and_role_id(stage.id, stage.class.base_class.to_s, role_id).size < 2

      errors.add(:role_id, I18n.t('performance.errors.stage_should_not_run_out_of_performances_with_first_role',
                             :role => stage.class.roles.sort.last.name))
      return false
    end
  end
end
