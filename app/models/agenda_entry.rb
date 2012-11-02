# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class AgendaEntry < ActiveRecord::Base
  belongs_to :agenda
  has_many :attachments, :dependent => :destroy
  accepts_nested_attributes_for :attachments, :allow_destroy => true
  attr_accessor :author, :duration, :date_update_action
  acts_as_stage
  acts_as_content :reflection => :agenda
  acts_as_resource

  validates_presence_of :title
  validates_presence_of :agenda, :start_time, :end_time

  # Minimum duration IN MINUTES of an agenda entry that is NOT excluded from recording
  MINUTES_NOT_EXCLUDED =  30

  #param that will be saved in the field video_type
  #automatic: if the user wants the automatic recorded video (only available if the event recording type is set to automatic or manual, i.e. the entry has video)
  #embedded: if the user discards the automatic and adds an embed
  #uploaded: if the user discards the automatic and uploads a new video
  #none: the user does not want video for this entry
  VIDEO_TYPE = [:automatic, :embedded, :uploaded, :none]

  before_validation do |agenda_entry|
    # Convert duration in end_time
    if agenda_entry.end_time.nil? || (agenda_entry.duration != agenda_entry.end_time - agenda_entry.start_time)
      agenda_entry.end_time = agenda_entry.start_time + agenda_entry.duration.to_i.minutes
    end

    # Fill attachment fields
    agenda_entry.attachments.each do |a|
      a.space  ||= agenda_entry.agenda.event.space
      a.event  ||= agenda_entry.agenda.event
      a.author ||= agenda_entry.author
    end
  end

  validate :validate_method
  def validate_method
    return if self.agenda.blank? || self.start_time.blank? || self.end_time.blank?

    if(self.start_time > self.end_time)
      self.errors.add(:base, I18n.t('agenda.entry.error.disordered_times'))
    end


    if (self.start_time < self.agenda.event.start_date) or (self.end_time > self.agenda.event.end_date)
      #debugger
      self.errors.add(:base, I18n.t('agenda.entry.error.out_of_event'))
      return
    end

    self.agenda.contents_for_day(self.event_day).each do |content|
      next if ( (content.class == AgendaEntry) && (content.id == self.id) )

      if (self.start_time <= content.start_time) && (self.end_time >= content.end_time)
        unless (content.start_time == content.end_time) && ((content.start_time == self.start_time) || (content.start_time == self.end_time))
          self.errors.add(:base, I18n.t('agenda.entry.error.coinciding_times'))
          return
        end
      elsif (content.start_time..content.end_time) === self.start_time
        unless (self.start_time == content.end_time) || ((self.start_time == content.start_time) && (self.start_time == self.end_time)) then
          self.errors.add(:base, I18n.t('agenda.entry.error.coinciding_times'))
          return
        end
      elsif (content.start_time..content.end_time) === self.end_time
        unless (self.end_time == content.start_time) || ((self.end_time == content.end_time) && (self.end_time == self.start_time)) then
          self.errors.add(:base, I18n.t('agenda.entry.error.coinciding_times'))
          return
        end
      end
    end

  end

  after_create do |entry|
    # This method should be uncomment when agenda_entry was created in one step (uncomment also after_update 2nd line)
    #    entry.attachments.each do |a|
    #      FileUtils.mkdir_p("#{Rails.root.to_s}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}")
    #      FileUtils.ln(a.full_filename, "#{Rails.root.to_s}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}/#{a.filename}")
    #    end
    FileUtils.mkdir_p("#{Rails.root.to_s}/attachments/conferences/#{entry.event.permalink}/#{entry.title.gsub(" ","_")}")
    if entry.uid.blank?
      entry.uid = entry.generate_uid + "@" + entry.id.to_s + ".vcc"
      entry.save
    end

    #check the correct option for video_type param in agenda_entry
    # if entry.event.is_in_person?
    #   entry.update_attribute(:video_type, AgendaEntry::VIDEO_TYPE.index(:none))
    # else
    #   entry.update_attribute(:video_type, AgendaEntry::VIDEO_TYPE.index(:automatic))
    # end

  end

  after_update do |entry|
    #Delete old attachments
    # FileUtils.rm_rf("#{Rails.root.to_s}/attachments/conferences/#{entry.event.permalink}/#{entry.title.gsub(" ","_")}")
    #create new attachments
    entry.attachments.reload
    entry.attachments.each do |a|
      # check if the attachment had already been created
      unless File.exist?("#{Rails.root.to_s}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}/#{a.filename}")
        FileUtils.mkdir_p("#{Rails.root.to_s}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}")
        FileUtils.ln(a.full_filename, "#{Rails.root.to_s}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}/#{a.filename}")
      end
    end
  end

  after_save do |entry|
    entry.event.agenda.touch
  end


  after_destroy do |entry|
    if entry.title.present?
      FileUtils.rm_rf("#{Rails.root.to_s}/attachments/conferences/#{entry.event.permalink}/#{entry.title.gsub(" ","_")}")
    end
  end

  def duration
    @duration ||= end_time - start_time
  end

  def space
    event.present? ? event.space : nil
  end

  def event
    agenda.present? ? agenda.event : nil
  end

  def recording?
    return false
  end

  def streaming?
    false
  end

  def thumbnail
    video_thumbnail.present? ?
    video_thumbnail :
      "default_background.jpg"
  end

  def past?
    return end_time.past?
  end

  #returns the day of the agenda entry, 1 for the first day, 2 for the second day, ...
  def event_day
    return ((self.start_time - event.start_date + event.start_date.hour.hours)/86400).floor + 1
  end


  def parse_embedded_video
    Nokogiri.parse embedded_video
  end

  def embedded_video_attribute(a)
    parse_embedded_video.xpath("//@#{ a }").first.try(:value)
  end

  def get_src_from_embed
    embedded_video_attribute("src")
  end

  def get_background_from_embed
   (get_src_from_embed) && (query = URI.parse(get_src_from_embed).query) && (CGI.parse(query)["image"].try(:first))
  end

  def is_happening_now?
    return start_time.past? && end_time.future?
  end

  def generate_uid

    Time.now.strftime("%Y%m%d%H%M%S").to_s + (1..18).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join.to_s.downcase

  end

=begin
  def to_json
    result = {}
    result[:title] = title
    result[:start] = "new Date(#{start_time.strftime "%y"},#{start_time.strftime "%m"},#{start_time.strftime "%d"},#{start_time.strftime "%H"},#{start_time.strftime "%M"})"
    result[:end] = "new Date(#{end_time.strftime "%y"},#{end_time.strftime "%m"},#{end_time.strftime "%d"},#{end_time.strftime "%H"},#{end_time.strftime "%M"})"
    result.to_json
  end
=end

  def video_unique_pageviews
    # Use only the canonical aggregated url of the video (all views have been previously added here in the rake task)
    corresponding_statistics = Statistic.find(:all, :conditions => ['url LIKE ?', '/spaces/' + self.space.permalink + '/videos/'+ self.id.to_s])
    if corresponding_statistics.size == 0
      return 0
    elsif corresponding_statistics.size == 1
      return corresponding_statistics.first.unique_pageviews
    elsif corresponding_statistics.size > 1
      raise "Incorrectly parsed statistics"
    end
  end

  def to_fullcalendar_json
      "{
         title: \"#{title ? sanitize_for_fullcalendar(title) : ''}\",
         start: new Date(#{start_time.strftime "%Y"},#{start_time.month-1},#{start_time.strftime "%d"},#{start_time.strftime "%H"},#{start_time.strftime "%M"}),
         end: new Date(#{end_time.strftime "%Y"},#{end_time.month-1},#{end_time.strftime "%d"},#{end_time.strftime "%H"},#{end_time.strftime "%M"}),
  allDay: false,
  id: #{id},
  description: \"#{description ? sanitize_for_fullcalendar(description) : ''}\",
         speakers: \"#{sanitize_for_fullcalendar(complete_speakers)}\",
         supertitle: \"#{divider ? sanitize_for_fullcalendar(divider) : ''}\"
       }"
end

private

def sanitize_for_fullcalendar(string)
  string.gsub("\r","").gsub("\n","<br />").gsub(/["]/, '\'')
end

def complete_speakers
 (actors + [speakers]).compact.map{ |a|
    a.is_a?(User) ?
    a.name :
     (a=="" ? nil : a)
  }.compact.join(", ")
end



end
