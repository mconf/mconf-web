require 'spec_helper'

feature "user registers in an event" do
  scenario "as a logged in user clicking in the link to register" do
    pending "redirects the user to the event's page"
    pending "updates the number of participants in the event"
    pending "adds the user as a participant in the event"
    pending "the event's page shows 'You are already registered in this event'"
    pending "the event's page doesn't show the register link"
  end

  scenario "as a visitor clicking in the link to register" do
    pending "redirects the page to register a new participant"
    pending "when the visitor enters an email, redirects to the event's home page"
    pending "adds the visitor's email as a participant in the event"
    pending "the event's page still shows the register link"
  end

  scenario "for an event that already ended" do
    pending "shows a message saying that the event ended"
    pending "doesn't show the register link"
  end

  scenario "as a logged in user in an event of a private space the user is not a member of" do
    pending "shows a link for the user to join the space"
    pending "doesn't show a link to register in the event"
  end

  scenario "as a logged in user in an event of a private space the user is a member of" do
    pending "shows a link to register in the event"
  end

  scenario "as a visitor in an event of a private space" do
    pending "shows a message saying that the user needs to sign in before registration"
    pending "doesn't show a link to register in the event"
  end
end
