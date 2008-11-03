class AddSitesTable < ActiveRecord::Migration
  def self.up
     create_table :sites do |t|
      t.string :name, :default => 'Virtual Conference Centre'
      t.text   :description
      t.string :domain, :default => 'sir.dit.upm.es'
      t.string :email, :default => 'vcc@sir.dit.upm.es'
      t.string :locale
      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end
