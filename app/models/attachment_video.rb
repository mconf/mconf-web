# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class AttachmentVideo < ActiveRecord::Base
  SWF_URL       = 'http://stream.globalplaza.org/reproductor/mediaplayer.swf'
  STREAMING_URL = 'rtmp://stream.globalplaza.org/venusStore/_definst_/'
  
  belongs_to :space
  belongs_to :event
  belongs_to :author, :polymorphic => true
  belongs_to :agenda_entry
  
  has_attachment :max_size => 1000.megabyte,
                 :path_prefix => 'attachment_videos',
                 :partition => false
                 
                 
  def space
    space_id.present? ?
      Space.find_with_disabled(space_id) :
      nil
  end
  
  
  validates_as_attachment
   
  def embed_html(width, height)
    <<-HTML
<embed name="player" src="#{ SWF_URL }?id=#{ filename }&amp;searchbar=false&amp;displayheight=356&amp;displaywidth=475&amp;autostart=true&amp;bufferlength=3&amp;file=#{ STREAMING_URL }" allowfullscreen="true" wmode="transparent" height="#{height}" width="#{width}">"
    HTML
  end
   
  def version_family
    Attachment.version_family(version_family_id)
  end
  
  def version
    version_family.reverse.index(self) +1
  end
  
  def current_version?
    version_child_id.nil?
  end

end
