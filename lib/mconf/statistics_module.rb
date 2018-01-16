module Mconf
  module StatisticsModule

    def self.total_users(from, to)
      result = {}

      puts from
      puts to

      users = User.where("created_at >= ? AND created_at < ?", from, to)

      #total users
      result[:all] = users.count

      # approved users
      result[:approved] = users.where(approved: true).count

      # disapproved users
      result[:not_approved] = users.where(approved: false).count

      # disabled users
      result[:disabled] = users.where(disabled: true).count

      result
    end

    def self.total_spaces(from, to)
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

    def self.total_meetings(from, to)
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

    def self.total_recordings(from, to)
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

    def self.generate(from =nil, to =nil)
      statistics = {
        users: {},
        spaces: {},
        meetings: {},
        recordings: {}
      }

      if from.blank?
        from = Time.at(0).utc
      end

      if to.blank?
        to =Time.now.utc
      end

      statistics[:users] = self.total_users(from, to)
      statistics[:spaces] = self.total_spaces(from, to)
      statistics[:meetings] = self.total_meetings(from, to)
      statistics[:recordings] = self.total_recordings(from, to)

      statistics
    end
  end
end
