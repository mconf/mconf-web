class CreateMachines < ActiveRecord::Migration
  def self.up
    create_table :machines do |t|
      t.column :name, :string, :null=>false, :limit=>40
      t.column :nickname, :string, :null=>false, :limit=>40       
    end
  end

  def self.down
    drop_table :machines
  end
end
