require 'spec_helper'
require 'support/feature_helpers'

feature "User registers in an event" do
  scenario "as a logged in user clicking in the link to register" do
    skip
    # redirects the user to the event's page
    # updates the number of participants in the event
    # adds the user as a participant in the event
    # the event's page shows 'You are already registered in this event'
    # the event's page doesn't show the register link
  end

  scenario "as a visitor clicking in the link to register" do
    skip
    # redirects the page to register a new participant
    # when the visitor enters an email, redirects to the event's home page
    # adds the visitor's email as a participant in the event
    # the event's page still shows the register link
  end

  scenario "for an event that already ended" do
    skip
    # shows a message saying that the event ended
    # doesn't show the register link
  end

  scenario "as a logged in user in an event of a private space the user is not a member of" do
    skip
    # shows a link for the user to join the space
    # doesn't show a link to register in the event
  end

  scenario "as a logged in user in an event of a private space the user is a member of" do
    skip
    # shows a link to register in the event
  end

  scenario "as a visitor in an event of a private space" do
    skip
    # shows a message saying that the user needs to sign in before registration
    # doesn't show a link to register in the event
  end
end
