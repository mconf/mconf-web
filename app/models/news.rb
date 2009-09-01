class News < ActiveRecord::Base
  belongs_to :space

  validates_presence_of :title, :text, :space_id

  acts_as_resource

  class << self
    def params_from_atom(entry)
      { :title => entry.title.to_s,
        :text => ( entry.content.to_s.present? ? entry.content.to_s : entry.title.to_s ) }
    end
  end
end
