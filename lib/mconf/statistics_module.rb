module Mconf
  module StatisticsModule

    def self.total_users(from, to)
      result = {}

      users = User.where("created_at >= ? AND created_at <= ?", from, to)

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

      spaces = Space.where("created_at >= ? AND created_at <= ?", from, to)

      #total_spaces
      result[:all] = spaces.all.count

      # private spaces
      result[:private] = spaces.where(public: false).count

      # public spaces
      result[:public] = spaces.where(public: true).count

      # disabled spaces
      result[:disabled] = spaces.where(disabled: true).count

      result
    end

    def self.total_meetings(from, to)
      result = {}

      meetings = BigbluebuttonMeeting.where("created_at >= ? AND created_at <= ?", from, to)

      total = 0
      duration = 0
      average = 0
      count = 0

      meetings.find_each do |m|
        # total duration
          unless m.finish_time == nil
            duration = m.finish_time - m.create_time
          end
          total = total + duration
          count = count + 1
      end

      # duration average
      result[:all] = count
      if count == 0
        result[:average] = 0
      else
        result[:average] = total / count
      end
      result[:total] = total

      result
    end

    def self.total_recordings(from, to)
      result = {}

      recordings = BigbluebuttonRecording.where("created_at >= ? AND created_at <= ?", from, to)

      total = 0
      duration = 0
      average = 0
      count = 0
      size = 0

      recordings.find_each do |r|
        # total duration
        duration = r.end_time - r.start_time
        total = total + duration
        size = size + r.size
        count = count + 1
      end

      # duration average
      result[:all] = count
      result[:size] = size
      if count == 0
        result[:average] = 0
      else
        result[:average] = total / count
      end
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

      statistics[:users] = self.total_users(from, to)
      statistics[:spaces] = self.total_spaces(from, to)
      statistics[:meetings] = self.total_meetings(from, to)
      statistics[:recordings] = self.total_recordings(from, to)

      statistics
    end

    def self.flatten_hash(hash)
      hash.each_with_object({}) do |(k, v), h|
        if v.is_a? Hash
          flatten_hash(v).map do |h_k, h_v|
            h["#{k}.#{h_k}".to_sym] = h_v
          end
        else
          h[k] = v
        end
      end
    end

    def self.generate_csv(from =nil, to =nil)
      data = self.generate(from, to)
      csv_data = self.flatten_hash(data)

      CSV.generate(headers: true) do |csv|
        csv << csv_data.keys
        csv << csv_data.values
      end
    end
  end
end
