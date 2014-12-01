#
# RecentActivity is a very flexible class which links models to activities which
# happen to pertrain those models. For example it is used to store when an user
# joins a space or when someone creates a new event.
#
# === Called from
# * Called from recent activity views in the home page and user page
# * Called from notifications via email in workers
#
# === Attributes
# Activities have many attributes and some are polymorphic, here's a quick rundown
# of how it looks like most of the time:
#
# * (trackable_id, trackable_type) trackable: The model to which the activity pertrains
# * (owner_id, owner_type) owner: Another model which is linked as owner of the activity. Typically this is the user which performed said activity
# * (recipient_id, recipient_type) recipient: Not used in any model for now
# * key: A string indicating the trackable model plus the action which happened
# * notified: A boolean informing whether the activity has already been notified inside a worker
# * parameters: Extra data about the activity which can be used to avoid extra database queries or store volatile data which may disappear or change in the future
#
# === Example of a valid activity model
# Ommiting active record and unused fields
#    <RecentActivity
#       id: 374,
#       trackable_id: 6, trackable_type: "JoinRequest",
#       owner_id: 3, owner_type: "Space",
#       key: "join_request.invite",
#       parameters:
#         {:candidate_id=>7,
#          :introducer=>"Emily Perez", :introducer_id=>3,
#          :username=>"Randy Lawrence"},
#       notified: nil>

class RecentActivity < PublicActivity::Activity
  # Used for home page and user page pagination
  self.per_page = 10
end
