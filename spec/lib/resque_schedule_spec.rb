require 'spec_helper'

describe Resque do
  let(:schedule) { Resque.schedule }

  # TODO: have to do this after running rake resque:setup or resque:scheduler
  #  to do so we have to setup a way to run rake tasks here

  skip("schedules PrivateMessagesWorker") {
    puts Resque.schedule.inspect
    should_have_scheduled(schedule, PrivateMessagesWorker, "30s")
  }
  skip("schedules JoinRequestsWorker") {
    should_have_scheduled(schedule, JoinRequestsWorker, "30s")
  }
  skip("schedules InvitationsWorker") {
    should_have_scheduled(schedule, InvitationsWorker, "30s")
  }
  skip("schedules UserNotificationsWorker") {
    should_have_scheduled(schedule, UserNotificationsWorker, "30s")
  }
  skip("schedules BigbluebuttonFinishMeetings") {
    should_have_scheduled(schedule, BigbluebuttonFinishMeetings, "30s")
  }
  skip("schedules BigbluebuttonUpdateRecordings") {
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
