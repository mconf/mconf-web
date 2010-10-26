class AgendaSlot < ActiveRecord::Migration
  def self.up
    add_column :agendas, :slot, :integer, :default => 15
  end

  def self.down
    remove_column :agendass, :slot
  end
end
