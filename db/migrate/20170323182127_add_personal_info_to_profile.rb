class AddPersonalInfoToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :cpf_cnpj, :string
    add_column :profiles, :service_usage, :string
  end

  def self.down
    remove_column :profiles, :cpf_cnpj
    remove_column :profiles, :service_usage
  end
end
