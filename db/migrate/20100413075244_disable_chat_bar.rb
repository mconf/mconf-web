class DisableChatBar < ActiveRecord::Migration
  def self.up
    change_column :users, :chat_activation, :boolean, :default => false
    
    User.all.each do |u|
      u.update_attribute :chat_activation, false
    end
  end

  def self.down
    change_column :users, :chat_activation, :boolean, :default => true
    
    User.all.each do |u|
      u.update_attribute :chat_activation, true
    end
  end
end
