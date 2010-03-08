class UserChatActivation < ActiveRecord::Migration
  def self.up
    add_column :users, :chat_activation, :boolean, :default => true
    
    User.all.each do |u|
      u.update_attribute :chat_activation, true
    end
  end

  def self.down
    remove_column :users, :chat_activation
  end
end
