module Mconf
  module StatisticsModule

    def total_users
      # approved users
      approved_users = User.where(approved: true).count

      # disapproved users
      approved_users = User.where(approved: false).count

      # disabled users
      disabled_users = User.where(disabled: true).count
    end

    def total_spaces
      # private spaces
      private_spaces = Space.where(public: false).count

      # public spaces
      public_spaces = Space.where(public: true).count

      # disabled spaces
      disabled_spaces = Space.where(disabled: true).count
    end

    def total_meetings
      total = 0
      duration = 0
      media = 0

      BigbluebuttonMeeting.each do |m|
        # total duration
          duration = m.finish_time - m.create_time
          total = total + duration
          count = count + 1
      end

      # duration media
      media = total / count
    end

    def total_recordings
      total = 0
      duration = 0
      media = 0

      BigbluebuttonRecording.each do |r|
        # total duration
        duration = r.end_time - r.start_time
        total = total + duration
        count = count + 1
      end

      # duration media
      media = total / count
    end
  end
end
