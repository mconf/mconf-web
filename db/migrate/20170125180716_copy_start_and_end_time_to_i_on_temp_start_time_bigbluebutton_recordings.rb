class CopyStartAndEndTimeToIOnTempStartTimeBigbluebuttonRecordings < ActiveRecord::Migration
  def up
    BigbluebuttonRecording.all.each do |rec|
      rec.update_attributes(
        temp_start_time: rec.start_time.to_i,
        temp_end_time: rec.end_time.to_i
      )
    end
  end
  def down
    BigbluebuttonRecording.all.each do |rec|
      rec.update_attributes(
        start_time: Time.at(rec.temp_start_time.to_i).strftime("%a, %d %b %Y %H:%M:%S %Z %z"),
        end_time: Time.at(rec.temp_end_time.to_i).strftime("%a, %d %b %Y %H:%M:%S %Z %z")
      )
    end
  end
end
