# Agents with OpenID Server have OpenID trusts when approve signing in a Remote Server
#
# The URI of the Remove Server is the trusted URI
#
class OpenIdTrust < ActiveRecord::Base
  belongs_to :agent, :polymorphic => true
  belongs_to :uri

  validates_presence_of :agent_id, :agent_type, :uri_id
end
