# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

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
   
  def embed_html
    <<-HTML
<embed name="player" src="#{ SWF_URL }?id=#{ filename }&amp;searchbar=false&amp;displayheight=356&amp;displaywidth=475&amp;autostart=true&amp;bufferlength=3&amp;file=#{ STREAMING_URL }" allowfullscreen="true" wmode="transparent" height="376" width="475">"
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
