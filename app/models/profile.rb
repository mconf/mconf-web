class Profile < ActiveRecord::Base
  belongs_to :user
  accepts_nested_attributes_for :user

  acts_as_taggable :container => false
  has_logo :class_name => "Avatar"
  
  # The order implies inclusion: everybody > members > public_fellows > private_fellows
  VISIBILITY = [:everybody, :members, :public_fellows, :private_fellows, :nobody]
  
  authorizing do |agent, permission|
    if self.user == agent
      true
    elsif (permission == :read)
      case visibility
        when VISIBILITY.index(:everybody)
          true
        when VISIBILITY.index(:members)
          agent != Anonymous.current
        when VISIBILITY.index(:public_fellows)
          self.user.public_fellows.include?(agent)
        when VISIBILITY.index(:private_fellows)
          self.user.private_fellows.include?(agent)
        when VISIBILITY.index(:nobody)
          false
      end
    end
  end
end
