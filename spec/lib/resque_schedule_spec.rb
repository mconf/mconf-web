require 'spec_helper'

describe Resque do
  let(:schedule) { Resque.schedule }

  it("schedules PrivateMessagesWorker") {
    should_have_scheduled(schedule, PrivateMessagesWorker, "30s")
  }
  it("schedules JoinRequestsWorker") {
    should_have_scheduled(schedule, JoinRequestsWorker, "30s")
  }
  it("schedules InvitationsWorker") {
    should_have_scheduled(schedule, InvitationsWorker, "30s")
  }
  it("schedules UserNotificationsWorker") {
    should_have_scheduled(schedule, UserNotificationsWorker, "30s")
  }
  it("schedules BigbluebuttonFinishMeetings") {
    should_have_scheduled(schedule, BigbluebuttonFinishMeetings, "30s")
  }
  it("schedules BigbluebuttonUpdateRecordings") {
    should_have_scheduled(schedule, BigbluebuttonUpdateRecordings, "30m")
  }

  def should_have_scheduled(schedule, searched, every=nil)
    classes = schedule.map do |schedule_item|
      config = schedule_item[1]
      config["class"]
    end
    classes.should include("#{searched}")

    unless every.nil?
      schedule.each do |schedule_item|
        if schedule_item[1]["class"] == "#{searched}"
          schedule_item[1]["every"].should include(every)
        end
      end
    end
  end

end
