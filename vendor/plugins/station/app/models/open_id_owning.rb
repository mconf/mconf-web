# Agents using OpenID authentication verify their OpenID URLs when singing in
#
# OpenIdOwning class stores the relation between the agent and the verified
# Uri
class OpenIdOwning < ActiveRecord::Base
  belongs_to :agent, :polymorphic => true
  belongs_to :uri

  named_scope :local, lambda { { :conditions => { :local => true } } }
  named_scope :remote, lambda { { :conditions => { :local => false } } }

  validates_presence_of :agent_id, :agent_type, :uri_id
end
