class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
       t.column :name, :string, :null=>false, :limit=>40
       t.column :password, :string, :null=>false, :limit=>40
       t.column :service, :string, :null=>false, :limit=>40
       t.column :quality, :string, :null=>false, :limit=>8
       t.column :description, :text, :null=>true
       t.column :uri, :string, :null=>false, :limit=>80
    end
  end

  def self.down
    drop_table :events
  end
end
