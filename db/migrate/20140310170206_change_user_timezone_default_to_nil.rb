class ChangeUserTimezoneDefaultToNil < ActiveRecord::Migration
  def change
    change_column_default :users, :timezone, nil
  end
end
