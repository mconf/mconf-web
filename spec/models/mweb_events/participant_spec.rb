require 'spec_helper'

describe MwebEvents::Participant do
  skip "abilities (using permissions, space admins, event organizers)"
  skip "activities"

  it { should have_one(:participant_confirmation) }
  skip '#create_participant_confirmation if annonymous?'
  skip '#annonymous?'
  skip '#email_confirmed?'
end
