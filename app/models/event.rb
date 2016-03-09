class Event < ActiveRecord::Base
  extend FriendlyId

  include PublicActivity::Common

  SOCIAL_NETWORKS = ['Facebook', 'Google Plus', 'Twitter', 'Linkedin']

  def self.host
    Site.current.domain
  end

  def new_activity key, user
    create_activity key, owner: owner, recipient: user, parameters: { username: user.try(:name), trackable_name: name }
  end

  # Temporary while we have no private events
  def public
    if owner_type == 'User'
      true # User owned spaces are always public
    elsif owner_type == 'Space'
      owner && owner.public?
    end
  end

  attr_accessor :date_display_format

  geocoded_by :address
  after_validation :geocode

  belongs_to :owner, :polymorphic => true
  has_many :participants, :dependent => :destroy

  validates :name, presence: true
  validates :start_on, presence: true
  validates :time_zone, presence: true
  validates :summary, length: {:maximum => 140}
  validates :owner, presence: true

  friendly_id :name, use: :slugged, :slug_column => :permalink
  validates :permalink, :presence => true

  # If the event has no ending date, use a day from start date
  before_save :check_end_on
  before_validation :check_summary

  # Test if we need to clear the coordinates because address was cleared
  before_save :check_coordinates

  scope :search_by_terms, -> (words, include_private=false) {
    words = words.join(' ') if words.is_a?(Array)
    where('name LIKE ?', "%#{words}%")
  }

  # Events that are happening currently
  scope :happening_now, lambda {
    where("start_on <= ? AND end_on > ?", Time.zone.now, Time.zone.now)
  }

  # Events that have already happened
  scope :past, lambda {
    where("end_on < ?", Time.zone.now)
  }

  # Events that are either in the future or are running now.
  scope :upcoming, lambda {
    where("end_on > ?", Time.zone.now)
  }

  # Events that happen between `from` and `to`
  scope :within, lambda { |from, to|
    where("(start_on >= ? AND start_on <= ?) OR (end_on >= ? AND end_on <= ?)", from, to, from, to)
  }

  # For form pretty display only
  attr_accessor :owner_name
  def owner_name
    @owner_name || owner.try(:name) || owner.try(:email)
  end

  def full_url
    Rails.application.routes.url_helpers.event_path(self, :host => Event.host, :only_path => false)
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  def description_html
    if not description.blank?
      require 'redcarpet'
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(escape_html: true))
      html = markdown.render description
    else
      html = I18n.t('events.no_description')
    end

    html
  end

  def social_networks=(networks)
    write_attribute(:social_networks , networks.select{|n| !n.empty?}.join(','))
  end

  def social_networks
    networks = read_attribute(:social_networks)
    networks ? networks.split(',') : []
  end

  def start_on_with_time_zone
    start_on.try(:in_time_zone, time_zone)
  end

  def end_on_with_time_zone
    end_on.try(:in_time_zone, time_zone)
  end

  # To format results on forms
  # Defaults to 'en' date format but can be set using event.date_display_format=
  def start_on_date
    if @start_on_date
      # showing date sent on last request
      @start_on_date
    else
      # fetching date from database and converting for display
      start_on_with_time_zone.strftime(date_display_format || "%m/%d/%Y") if start_on
    end
  end

  def start_on_time
    start_on_with_time_zone
  end

  def end_on_date
    if @end_on_date
      @end_on_date
    else
      end_on_with_time_zone.strftime(date_display_format || "%m/%d/%Y") if end_on
    end
  end

  def end_on_time
    end_on_with_time_zone
  end

  def to_ical
    calendar = Icalendar::Calendar.new
    calendar.add_event(to_ics_internal)
    calendar.publish
    calendar.to_ical
  end
  alias_method :to_ics, :to_ical

  # Returns wheter the event has already happaned and is finished
  def past?
    end_on.past?
  end

  # Returns whether the event is happening now or not.
  def is_happening_now?
    if start_on.past? && end_on.future?
      true
    else
      false
    end
  end

  # Returns whether the event will happen in the future or not.
  def future?
    start_on.future?
  end

  # Returns a string with the starting hour of an event in the correct format
  def get_formatted_hour
    start_on.strftime("%H:%M")
  end

  # Returns a string with the starting date of an event in the correct format
  def get_formatted_date(date=nil, with_tz=true)
    if date.nil?
      if with_tz
        I18n::localize(start_on, :format => "%A, %d %b %Y, %H:%M (#{time_zone})")
      else
        I18n::localize(start_on, :format => "%A, %d %b %Y, %H:%M")
      end
    else
      if with_tz
        I18n::localize(date, :format => "%A, %d %b %Y, %H:%M (#{time_zone})")
      else
        I18n::localize(date, :format => "%A, %d %b %Y, %H:%M")
      end
    end
  end

  # Currently unused
  def get_formatted_timezone(date=nil)
    if date.nil?
      "GMT#{start_on_with_time_zone.formatted_offset}"
    else
      "GMT#{date.in_time_zone(time_zone).formatted_offset}"
    end
  end

  # Returns whether a user (any model) or email (a string) is already registered in this event.
  def is_registered?(user_or_email)
    if user_or_email.is_a?(String)
      Participant.where(:email => user_or_email, :event_id => id).any?
    else
      Participant.where(:owner_type => user_or_email.class.name, :owner_id => user_or_email.id,
                        :event_id => id).any?
    end
  end

  private

  def to_ics_internal
    event = Icalendar::Event.new
    event.dtstart = start_on.strftime("%Y%m%dT%H%M%SZ")
    event.dtend = end_on.strftime("%Y%m%dT%H%M%SZ") if !end_on.blank?
    event.summary = name
    event.organizer = owner_name
    event.description = summary
    event.location = "#{location}"
    event.location += " - #{address}" if !address.blank?
    event.ip_class = "PUBLIC"
    event.created = created_at.strftime("%Y%m%dT%H%M%S")
    event.last_modified = updated_at.strftime("%Y%m%dT%H%M%S")
    event.uid = full_url
    event.url = full_url
    event
  end

  def check_end_on
    write_attribute(:end_on, start_on + 1.day) if end_on.blank?

    # Swap dates if it ends before it starts
    if end_on < start_on
      tmp = start_on
      write_attribute(:start_on, end_on)
      write_attribute(:end_on, tmp)
    end
  end

  def check_summary
    if summary.blank?
      s = HTML::FullSanitizer.new.sanitize(description_html).truncate(136, :omission => '...')
      write_attribute(:summary, s)
    end
  end

  def check_coordinates
    if persisted? && address.blank?
      write_attribute(:longitude, nil)
      write_attribute(:latitude, nil)
    end
  end
end
