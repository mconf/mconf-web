# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.


module RecordingsHelper
  def recording_published(recording)
    if recording.published?
      content_tag :div, class: 'label label-recording-published' do
        concat t('_other.recording.published')
      end
    else
      content_tag :div, class: 'label label-recording-unpublished' do
        concat t('_other.recording.unpublished')
      end
    end
  end

  def recording_available(recording)
    if recording.available?
      content_tag :div, class: 'label label-recording-available' do
        concat t('_other.recording.available')
      end
    else
      content_tag :div, class: 'label label-recording-unavailable' do
        concat t('_other.recording.unavailable')
      end
    end
  end

  def recording_size(recording)
    content_tag :div, class: 'label label-recording-size' do
      concat human_file_size(recording.size)
    end
  end
end
