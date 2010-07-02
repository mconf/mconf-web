class ChangeDefaultProfileVisibility < ActiveRecord::Migration
  def self.up
    change_column :profiles, :visibility, :integer, :default => Profile::VISIBILITY.index(:private_fellows)
  end

  def self.down
    change_column :profiles, :visibility, :integer, :default => Profile::VISIBILITY.index(:public_fellows)
  end
end
