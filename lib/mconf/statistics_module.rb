module Mconf
  module StatisticsModule

    def self.total_users(from, to)
      result = {}

      users = User.with_disabled.where("created_at >= ? AND created_at <= ?", from, to)

      #total users
      result[:count] = users.count

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

      spaces = Space.with_disabled.where("created_at >= ? AND created_at <= ?", from, to)

      #total_spaces
      result[:count] = spaces.all.count

      # private spaces
      result[:private] = spaces.where(public: false).count

      # public spaces
      result[:public] = spaces.where(public: true).count

      # disabled spaces
      result[:disabled] = spaces.where(disabled: true).count

      result
    end

    def self.total_meetings(from, to)
      meetings = BigbluebuttonMeeting.where("created_at >= ? AND created_at <= ?", from, to)

      result = {}
      result[:count] = meetings.count
      result[:total_duration] = meetings.sum('finish_time - create_time')
      if result[:count].zero? || result[:count].nil?
        result[:average_duration] = 0
      else
        result[:average_duration] = result[:total_duration] / result[:count]
      end

      result
    end

    def self.total_recordings(from, to)
      recordings = BigbluebuttonRecording.where("created_at >= ? AND created_at <= ?", from, to)

      result = {}
      result[:count] = recordings.count
      result[:size] = recordings.sum(:size)
      result[:total_duration] = recordings.sum('end_time - start_time')
      if result[:count].zero? || result[:count].nil?
        result[:average_duration] = 0
      else
        result[:average_duration] = result[:total_duration] / result[:count]
      end

      result
    end

    def self.generate(from, to)
      statistics = {
        users: {},
        spaces: {},
        meetings: {},
        recordings: {}
      }

      from.present? ? from = from.beginning_of_day : nil
      to.present? ? to = to.end_of_day : nil

      statistics[:users] = self.total_users(from, to)
      statistics[:spaces] = self.total_spaces(from, to)
      statistics[:meetings] = self.total_meetings(from, to)
      statistics[:recordings] = self.total_recordings(from, to)

      statistics
    end

    def self.generate_csv(from, to)
      unless from.blank? || to.blank?
        data = self.generate(from, to)
        csv_data = self.flatten_hash(data)

        CSV.generate(headers: true) do |csv|
          csv << csv_data.keys
          csv << csv_data.values
        end
      end
    end

    private

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
  end
end
