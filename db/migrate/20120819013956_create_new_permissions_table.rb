class CreateNewPermissionsTable < ActiveRecord::Migration
  def up
    create_table "permissions_tmp", :force => true do |t|
      t.integer "user_id",       :null => false
      t.integer "subject_id",    :null => false
      t.string "subject_type",   :null => false
      t.integer "role_id",       :null => false
      t.timestamps
    end

    connection = ActiveRecord::Base.connection()

    # map old permissions to the new table
    select = "SELECT `performances`.`id` AS t0_r0,
                     `performances`.`agent_id` AS t0_r1,
                     `performances`.`agent_type` AS t0_r2,
                     `performances`.`role_id` AS t0_r3,
                     `performances`.`stage_id` AS t0_r4,
                     `performances`.`stage_type` AS t0_r5,
                     `performances`.`created_at` AS t0_r6,
                     `performances`.`updated_at` AS t0_r7,
                     `roles`.`id` AS t1_r0,
                     `roles`.`name` AS t1_r1,
                     `roles`.`stage_type` AS t1_r2
                     FROM `performances` LEFT OUTER JOIN `roles`
                     ON `roles`.`id` = `performances`.`role_id`
                     WHERE (roles.name in ('Admin','User','Organizer'))"
    values = []
    connection.execute(select).each do |row|
      v = "(#{row[1]}, #{row[4]}, '#{row[5]}', #{row[3]})"
      values.push v
    end
    if values.count > 0
      cols = "(user_id, subject_id, subject_type, role_id)"
      sql = "INSERT INTO permissions_tmp #{cols} VALUES #{values.join(", ")}"
      connection.execute sql
    end
  end

  def down
    drop_table "permissions_tmp"
  end
end
