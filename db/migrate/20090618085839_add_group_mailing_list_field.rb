class AddGroupMailingListField < ActiveRecord::Migration
  def self.up
    add_column :groups, :mailing_list, :string
  end

  def self.down
    remove_column :groups, :mailing_list
  end
end
