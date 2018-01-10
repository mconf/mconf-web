module Mconf
  module StatisticsModule

    def self.total_users
      result = {}

      #total users
      result[:all] = User.all.count

      # approved users
      result[:approved] = User.where(approved: true).count

      # disapproved users
      result[:not_approved] = User.where(approved: false).count

      # disabled users
      result[:disabled] = User.where(disabled: true).count

      result
    end

    def self.total_spaces
      result = {}

      #total_spaces
      result[:all] = Space.all.count

      # private spaces
      result[:private] = Space.where(public: false).count

      # public spaces
      result[:public] = Space.where(public: true).count

      # disabled spaces
      result[:disabled] = Space.where(disabled: true).count

      result
    end

    def self.total_meetings
      result = {}

      total = 0
      duration = 0
      average = 0
      count = 0

      BigbluebuttonMeeting.find_each do |m|
        # total duration
          unless m.finish_time == nil
            duration = m.finish_time - m.create_time
          end
          total = total + duration
          count = count + 1
      end

      # duration average
      result[:all] = count
      result[:average] = total / count
      result[:total] = total

      result
    end

    def self.total_recordings
      result = {}

      total = 0
      duration = 0
      average = 0
      count = 0

      BigbluebuttonRecording.find_each do |r|
        # total duration
        duration = r.end_time - r.start_time
        total = total + duration
        count = count + 1
      end

      # duration average
      result[:all] = count
      result[:average] = total / count
      result[:total] = total

      result
    end

    def self.generate
      statistics = {
        users: {},
        spaces: {},
        meetings: {},
        recordings: {}
      }

      statistics[:users] = self.total_users
      statistics[:spaces] = self.total_spaces
      statistics[:meetings] = self.total_meetings
      statistics[:recordings] = self.total_recordings

      statistics
    end
  end
end
