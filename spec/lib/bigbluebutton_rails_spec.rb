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
          target.get_create_options.call(room).should have_key(:"meta_mconfweb-url")
          target.get_create_options.call(room).should have_key(:"meta_mconfweb-room-type")
          target.get_create_options.call(room)[:"meta_mconfweb-url"].should eql("http://#{Site.current.domain}/")
          target.get_create_options.call(room)[:"meta_mconfweb-room-type"].should eql("User")
        }
      end

      context "for a space room" do
        before {
          room.update_attributes(owner: FactoryGirl.create(:space))
        }

        it {
          target.get_create_options.call(room).should have_key(:"meta_mconfweb-url")
          target.get_create_options.call(room).should have_key(:"meta_mconfweb-room-type")
          target.get_create_options.call(room)[:"meta_mconfweb-url"].should eql("http://#{Site.current.domain}/")
          target.get_create_options.call(room)[:"meta_mconfweb-room-type"].should eql("Space")
        }
      end

      context "works with HTTPS" do
        before {
          Site.current.update_attributes(ssl: true)
          room.update_attributes(owner: FactoryGirl.create(:space))
        }

        it {
          target.get_create_options.call(room).should have_key(:"meta_mconfweb-url")
          target.get_create_options.call(room).should have_key(:"meta_mconfweb-room-type")
          target.get_create_options.call(room)[:"meta_mconfweb-url"].should eql("https://#{Site.current.domain}/")
          target.get_create_options.call(room)[:"meta_mconfweb-room-type"].should eql("Space")
        }
      end
    end

    context "sets the record flag" do

      context "when config.per_user_record_permissions is true" do
        before {
          @previous = Rails.application.config.per_user_record_permissions
          Rails.application.config.per_user_record_permissions = true
        }
        after {
          Rails.application.config.per_user_record_permissions = @previous
        }

        context "if there's no user logged" do
          it {
            target.get_create_options.call(room, nil).should have_key(:record)
            target.get_create_options.call(room, nil)[:record].should be(true)
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
                  target.get_create_options.call(room, user)[:record].should be(true)
                }
              end

              context "and the room is not set to record" do
                before { room.update_attributes(record_meeting: false) }
                it {
                  target.get_create_options.call(room, nil).should have_key(:record)
                  target.get_create_options.call(room, nil)[:record].should be(true)
                }
              end
            end
          end
        end
      end

      context "when config.per_user_record_permissions is false" do
        before {
          @previous = Rails.application.config.per_user_record_permissions
          Rails.application.config.per_user_record_permissions = false
        }
        after {
          Rails.application.config.per_user_record_permissions = @previous
        }

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
    end

    context "sets the 'wont record' message" do
      let(:user) { FactoryGirl.create(:user) }

      context "when config.per_user_record_permissions is false" do
        before {
          @previous = Rails.application.config.per_user_record_permissions
          Rails.application.config.per_user_record_permissions = false
        }
        after {
          Rails.application.config.per_user_record_permissions = @previous
        }

        context "if the user doesn't have permission to record meetings" do
          let(:msg) { I18n.t('users.cant_record_reason.user_cannot_record') }
          before { user.update_attributes(can_record: false) }

          it {
            target.get_create_options.call(room, user).should have_key(:"meta_mconf-live-wont-record-message")
            target.get_create_options.call(room, user)[:"meta_mconf-live-wont-record-message"].should eql(msg)
          }
        end

        context "if it's an anonymous user" do
          let(:msg) { I18n.t('users.cant_record_reason.user_cannot_record') }
          it {
            target.get_create_options.call(room, nil).should have_key(:"meta_mconf-live-wont-record-message")
            target.get_create_options.call(room, nil)[:"meta_mconf-live-wont-record-message"].should eql(msg)
          }
        end

        context "if the user has permission to record meetings" do
          let(:room) { user.bigbluebutton_room }
          before { user.update_attributes(can_record: true) }

          it {
            target.get_create_options.call(room, user).should_not have_key(:"meta_mconf-live-wont-record-message")
            target.get_create_options.call(room, user).should_not have_key("meta_mconf-live-wont-record-message")
          }
        end
      end

      context "when config.per_user_record_permissions is true" do
        before {
          @previous = Rails.application.config.per_user_record_permissions
          Rails.application.config.per_user_record_permissions = true
        }
        after {
          Rails.application.config.per_user_record_permissions = @previous
        }

        before { user.update_attributes(can_record: false) }
        it {
          target.get_create_options.call(room, user).should_not have_key(:"meta_mconf-live-wont-record-message")
          target.get_create_options.call(room, user).should_not have_key("meta_mconf-live-wont-record-message")
        }
      end
    end
  end

  describe "#get_join_options" do
    let(:target) { BigbluebuttonRails.configuration }
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }

    it { target.should respond_to(:get_join_options) }
    it { target.get_create_options.should be_a(Proc) }

    context "sets the record userdata" do

      context "when config.per_user_record_permissions is true" do
        before {
          @previous = Rails.application.config.per_user_record_permissions
          Rails.application.config.per_user_record_permissions = true
        }
        after {
          Rails.application.config.per_user_record_permissions = @previous
        }

        context "if there's no user logged" do
          it {
            target.get_join_options.call(room, nil).should have_key(:'userdata-record')
            target.get_join_options.call(room, nil)[:'userdata-record'].should be(false)
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
                  target.get_join_options.call(room, user).should have_key(:'userdata-record')
                  target.get_join_options.call(room, user)[:'userdata-record'].should be(true)
                }
              end

              context "and the room is not set to record" do
                before { room.update_attributes(record_meeting: false) }
                it {
                  target.get_join_options.call(room, user).should have_key(:'userdata-record')
                  target.get_join_options.call(room, user)[:'userdata-record'].should be(true)
                }
              end
            end

            context "when the user cannot record" do
              before { @ability.cannot :record_meeting, room }

              context "and the room is set to record" do
                before { room.update_attributes(record_meeting: true) }
                it {
                  target.get_join_options.call(room, user).should have_key(:'userdata-record')
                  target.get_join_options.call(room, user)[:'userdata-record'].should be(false)
                }
              end

              context "and the room is not set to record" do
                before { room.update_attributes(record_meeting: false) }
                it {
                  target.get_join_options.call(room, nil).should have_key(:'userdata-record')
                  target.get_join_options.call(room, nil)[:'userdata-record'].should be(false)
                }
              end
            end
          end
        end
      end

      context "when config.per_user_record_permissions is false" do
        before {
          @previous = Rails.application.config.per_user_record_permissions
          Rails.application.config.per_user_record_permissions = false
        }
        after {
          Rails.application.config.per_user_record_permissions = @previous
        }

        context "if there's no user logged" do
          it {
            target.get_join_options.call(room, nil).should_not have_key(:'userdata-record')
          }
        end

        context "if there's a user logged that can record" do
          let(:user) { FactoryGirl.create(:user) }
          before {
            # a custom ability to control what the user can do
            @ability = Object.new
            @ability.extend(CanCan::Ability)
            Abilities.stub(:ability_for).and_return(@ability)
            @ability.can :record_meeting, room
            room.update_attributes(record_meeting: true)
          }

          it {
            target.get_join_options.call(room, nil).should_not have_key(:'userdata-record')
          }
        end
      end

    end

    context "sets the 'wont record' message" do
      let(:user) { FactoryGirl.create(:user) }

      context "when config.per_user_record_permissions is true" do
        before {
          @previous = Rails.application.config.per_user_record_permissions
          Rails.application.config.per_user_record_permissions = true
        }
        after {
          Rails.application.config.per_user_record_permissions = @previous
        }

        context "if the user doesn't have permission to record meetings" do
          let(:msg) { I18n.t('users.cant_record_reason.user_cannot_record') }
          before { user.update_attributes(can_record: false) }

          it {
            target.get_join_options.call(room, user).should have_key(:"userdata-disabled_record_reason")
            target.get_join_options.call(room, user)[:"userdata-disabled_record_reason"].should eql(msg)
          }
        end

        context "if it's an anonymous user" do
          let(:msg) { I18n.t('users.cant_record_reason.user_cannot_record') }

          it {
            target.get_join_options.call(room, nil).should have_key(:"userdata-disabled_record_reason")
            target.get_join_options.call(room, nil)[:"userdata-disabled_record_reason"].should eql(msg)
          }
        end

        context "if the user has permission to record meetings" do
          let(:room) { user.bigbluebutton_room }
          before { user.update_attributes(can_record: true) }

          it {
            target.get_join_options.call(room, user).should_not have_key(:"userdata-disabled_record_reason")
            target.get_join_options.call(room, user).should_not have_key("userdata-disabled_record_reason")
          }
        end
      end

      context "when config.per_user_record_permissions is false" do
        before {
          @previous = Rails.application.config.per_user_record_permissions
          Rails.application.config.per_user_record_permissions = false
        }
        after {
          Rails.application.config.per_user_record_permissions = @previous
        }

        context "if the user doesn't have permission to record meetings" do
          let(:msg) { I18n.t('users.cant_record_reason.user_cannot_record') }
          before { user.update_attributes(can_record: false) }

          it {
            target.get_join_options.call(room, user).should_not have_key(:"userdata-disabled_record_reason")
            target.get_join_options.call(room, user).should_not have_key("userdata-disabled_record_reason")
          }
        end

        context "if it's an anonymous user" do
          let(:msg) { I18n.t('users.cant_record_reason.user_cannot_record') }

          it {
            target.get_join_options.call(room, nil).should_not have_key(:"userdata-disabled_record_reason")
            target.get_join_options.call(room, nil).should_not have_key("userdata-disabled_record_reason")
          }
        end
      end
    end
  end
end
