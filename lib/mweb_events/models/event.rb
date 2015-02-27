MwebEvents::Event.class_eval do
  include PublicActivity::Common

  has_many :permissions, -> { where(:subject_type => 'MwebEvents::Event') }, :foreign_key => "subject_id"

  has_and_belongs_to_many :organizers, -> { Permission.where(:subject_type => 'MwebEvents::Event') },
    :class_name => "User", :join_table => :permissions, :foreign_key => "subject_id"

  def self.organizer_role
    Role.where(stage_type: 'MwebEvents::Event', name: 'Organizer').first
  end

  def self.host
    Site.current.domain || 'example.com'
  end

  def new_activity key, user
    create_activity key, :owner => owner, :parameters => { :user_id => user.try(:id), :username => user.try(:name) }
  end

  def add_organizer! user
    permissions.create(user: user, role: MwebEvents::Event.organizer_role)
  end

  # Temporary while we have no private events
  def public
    if owner_type == 'User'
      true # User owned spaces are always public
    elsif owner_type == 'Space'
      owner && owner.public?
    end
  end
end
