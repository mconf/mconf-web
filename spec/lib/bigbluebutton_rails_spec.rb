# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonRails do

  describe "#invitation_url" do
    let(:target) { BigbluebuttonRails.configuration }
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    before {
      Site.current.update_attributes(domain: "localhost:4000")
    }
    set_conf_scope_rooms('webconf')

    it { target.should respond_to(:get_invitation_url) }
    it { target.get_invitation_url.should be_a(Proc) }
    it { target.get_invitation_url.call(room).should eql("http://#{Site.current.domain}/webconf/#{room.slug}") }

    context "works with HTTPS" do
      before {
        Site.current.update_attributes(ssl: true)
      }

      it { target.get_invitation_url.call(room).should eql("https://#{Site.current.domain}/webconf/#{room.slug}") }
    end
  end

  describe "#get_create_options" do
    let(:target) { BigbluebuttonRails.configuration }
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    before {
      Site.current.update_attributes(domain: "localhost:4000")
    }

    it { target.should respond_to(:get_create_options) }
    it { target.get_create_options.should be_a(Proc) }

    context "sets the metadata" do
      context "for a user room" do
        before {
          room.update_attributes(owner: FactoryGirl.create(:user))
        }

        it {
          target.get_create_options.call(room).should have_key("meta_mconfweb-url")
          target.get_create_options.call(room).should have_key("meta_mconfweb-room-type")
          target.get_create_options.call(room)["meta_mconfweb-url"].should eql("http://#{Site.current.domain}/")
          target.get_create_options.call(room)["meta_mconfweb-room-type"].should eql("User")
        }
      end

      context "for a space room" do
        before {
          room.update_attributes(owner: FactoryGirl.create(:space))
        }

        it {
          target.get_create_options.call(room).should have_key("meta_mconfweb-url")
          target.get_create_options.call(room).should have_key("meta_mconfweb-room-type")
          target.get_create_options.call(room)["meta_mconfweb-url"].should eql("http://#{Site.current.domain}/")
          target.get_create_options.call(room)["meta_mconfweb-room-type"].should eql("Space")
        }
      end

      context "works with HTTPS" do
        before {
          Site.current.update_attributes(ssl: true)
          room.update_attributes(owner: FactoryGirl.create(:space))
        }

        it {
          target.get_create_options.call(room).should have_key("meta_mconfweb-url")
          target.get_create_options.call(room).should have_key("meta_mconfweb-room-type")
          target.get_create_options.call(room)["meta_mconfweb-url"].should eql("https://#{Site.current.domain}/")
          target.get_create_options.call(room)["meta_mconfweb-room-type"].should eql("Space")
        }
      end
    end

    context "sets the record flag" do
      context "if there's no user logged" do
        it {
          target.get_create_options.call(room, nil).should have_key(:record)
          target.get_create_options.call(room, nil)[:record].should be(false)
        }
      end

      context "if there's a user logged" do
        let(:user) { FactoryGirl.create(:user) }
        before {
          # a custom ability to control what the user can do
          @ability = Object.new
          @ability.extend(CanCan::Ability)
          Abilities.stub(:ability_for).and_return(@ability)
        }

        context "sets the record option" do
          context "when the user can record" do
            before { @ability.can :record_meeting, room }

            context "and the room is set to record" do
              before { room.update_attributes(record_meeting: true) }
              it {
                target.get_create_options.call(room, user).should have_key(:record)
                target.get_create_options.call(room, user)[:record].should be(true)
              }
            end

            context "and the room is not set to record" do
              before { room.update_attributes(record_meeting: false) }
              it {
                target.get_create_options.call(room, user).should have_key(:record)
                target.get_create_options.call(room, user)[:record].should be(true)
              }
            end
          end

          context "when the user cannot record" do
            before { @ability.cannot :record_meeting, room }

            context "and the room is set to record" do
              before { room.update_attributes(record_meeting: true) }
              it {
                target.get_create_options.call(room, user).should have_key(:record)
                target.get_create_options.call(room, user)[:record].should be(false)
              }
            end

            context "and the room is not set to record" do
              before { room.update_attributes(record_meeting: false) }
              it {
                target.get_create_options.call(room, nil).should have_key(:record)
                target.get_create_options.call(room, nil)[:record].should be(false)
              }
            end
          end
        end
      end
    end

    context "sets the max participants flag" do
      let(:free_limit) { Rails.application.config.free_attendee_limit }
      before {
        room.update_attributes(max_participants: nil)
      }

      context "when the room belongs to a user" do
        let(:user) { FactoryGirl.create(:user) }
        before { room.update_attributes(owner: user) }

        context "and already has a max_participants set in the db" do
          before {
            room.update_attributes(max_participants: 123)
          }
          it {
            target.get_create_options.call(room, nil).should have_key(:max_participants)
            target.get_create_options.call(room, nil)[:max_participants].should eql(123)
          }
        end

        context "when the user has no subscription" do
          it {
            target.get_create_options.call(room, nil).should have_key(:max_participants)
            target.get_create_options.call(room, nil)[:max_participants].should eql(free_limit)
          }
        end

        context "when the user has a subscription" do
          before {
            Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
            Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
            Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
            Mconf::Iugu.stub(:update_customer).and_return(true)
          }

          let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
          it {
            target.get_create_options.call(room, nil).should have_key(:max_participants)
            target.get_create_options.call(room, nil)[:max_participants].should eql(nil)
          }
        end
      end

      context "when the room belongs to a space" do
        let(:space) { FactoryGirl.create(:space) }
        before { room.update_attributes(owner: space) }

        context "and the room has no max_participants set" do
          it {
            target.get_create_options.call(room, nil).should have_key(:max_participants)
            target.get_create_options.call(room, nil)[:max_participants].should eql(nil)
          }
        end

        context "and already has a max_participants set in the db" do
          before {
            room.update_attributes(max_participants: 123)
          }
          it {
            target.get_create_options.call(room, nil).should have_key(:max_participants)
            target.get_create_options.call(room, nil)[:max_participants].should eql(123)
          }
        end
      end
    end
  end
end
