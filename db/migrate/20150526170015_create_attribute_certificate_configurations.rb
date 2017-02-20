class CreateAttributeCertificateConfigurations < ActiveRecord::Migration
  def change
    create_table :attribute_certificate_configurations do |t|
      t.boolean :enabled, default: false
      t.string :repository_url
      t.string :repository_port
      t.timestamps
    end
  end
end
