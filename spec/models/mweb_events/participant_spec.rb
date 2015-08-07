# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe MwebEvents::Participant do
  skip "abilities (using permissions, space admins, event organizers)"
  skip "activities"

  it { should have_one(:participant_confirmation) }
  skip '#create_participant_confirmation if annonymous?'
  skip '#annonymous?'
  skip '#email_confirmed?'
end
