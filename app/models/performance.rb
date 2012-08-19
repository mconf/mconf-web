# -*- coding: utf-8 -*-
# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

# Require Station Model

# class Performance < ActiveRecord::Base
#   after_create { |perfor|
#     user = perfor.agent

#     if perfor.stage.is_a?(Event) && perfor.agent.is_a?(User) && !(perfor.stage.space.role_for? perfor.agent)
#       Performance.create! :agent => perfor.agent,
#                           :stage => perfor.stage.space,
#                           :role  => Role.find_by_name("Invited")
#     end
#   }

#   # Destroy Space admission after leaving the Space
#   after_destroy { |p|
#     if p.stage.is_a?(Space) && p.agent.is_a?(User)
#       space = p.stage
#       p.stage.admissions.find_by_candidate_id_and_candidate_type(p.agent.id, p.agent.class.base_class.to_s).try(:destroy)
#     end
#   }

#   # Authorize the XMPP Server reading Performances
#   authorizing do |agent, permission|
#     if permission == :read && agent.is_a?(XmppServer)
#       true
#     end
#   end

#   # FIXME: provide support in Station to insert Authorization Blocks before
#   authorizing do |agent, permission|
#     if agent == self.agent
#       if permission == :delete
#         true
#       end
#     end
#   end

#   def to_xml(options = {})
#     options[:indent] ||= 2
#     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
#     xml.instruct! unless options[:skip_instruct]
#     xml.performance do
#       xml.agent do
#         xml.id agent.id
#         xml.type agent.type
#         xml.login(agent.username) if agent.respond_to?(:username)
#       end
#       xml.role do
#         xml.id role.id
#         xml.name role.name
#       end
#       xml.stage do
#         xml.id stage.id
#         xml.type stage.type
#       end
#     end
#   end

#   #-#-# from station

#   belongs_to :agent, :polymorphic => true
#   belongs_to :stage, :polymorphic => true
#   belongs_to :role

#   acts_as_resource
#   acts_as_sortable :columns => [ { :content => :agent,
#                                    :sortable => false },
#                                  { :name => :role,
#                                    :render => 'edit_role_form',
#                                    :sortable => true }
#                                ]

#   scope :stage_type, lambda { |type|
#     type ?
#       { :conditions => [ "stage_type = ?", type.to_s.classify ] } :
#       {}
#   }

#   validates_presence_of :agent_id, :agent_type, :stage_id, :stage_type, :role_id
#   validates_uniqueness_of :agent_id, :scope => [ :agent_type, :stage_id, :stage_type ]
#   validates_uniqueness_of :agent_type, :scope => [ :agent_id, :stage_id, :stage_type ]

#   # Avoid a Stage running from Performances with the most important Role
#   validate :avoid_downgrading_only_one_with_highest_role, :on => :update

#   validate :role_belongs_to_same_stage

#   before_destroy :avoid_destroying_only_one_with_highest_role

#   private

#   # Avoids the only Admin to change his role to a lower one
#   def avoid_downgrading_only_one_with_highest_role
#     if role_id_changed? &&
#        role_id_was == stage.class.roles.sort.last.id &&
#        Performance.find_all_by_stage_id_and_stage_type_and_role_id(stage.id, stage.class.base_class.to_s, role_id_was).size < 2

#       errors.add(:role_id, I18n.t('performance.errors.stage_should_not_run_out_of_performances_with_first_role',
#                              :role => stage.class.roles.sort.last.name))
#     end
#   end

#   # Avoids the only Admin to leave the Stage
#   def avoid_destroying_only_one_with_highest_role
#     if role == stage.class.roles.sort.last &&
#        Performance.find_all_by_stage_id_and_stage_type_and_role_id(stage.id, stage.class.base_class.to_s, role_id).size < 2

#       errors.add(:role_id, I18n.t('performance.errors.stage_should_not_run_out_of_performances_with_first_role',
#                              :role => stage.class.roles.sort.last.name))
#       return false
#     end
#   end

#   def role_belongs_to_same_stage

#     if role.stage_type != stage_type
#       errors.add(:role_id, I18n.t('performance.errors.the_role_should_not_belong_to_a_different_stage_type'))
#     end

#   end

# end
