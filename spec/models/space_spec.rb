# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Space do
  let(:space) { FactoryGirl.create(:space) }

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:space).should be_valid
  end

  describe "initializes with default values" do
    it { Space.new.repository.should be(false) }
    it { Space.new(repository: true).repository.should be(true) }
    it { Space.new.public.should be(false) }
    it { Space.new(public: true).public.should be(true) }
    it { Space.new.disabled.should be(false) }
    it { Space.new(disabled: true).disabled.should be(true) }
  end

  it { should have_many(:posts).dependent(:destroy) }
  it { should have_many(:events).dependent(:destroy) }
  it { should have_many(:attachments).dependent(:destroy) }

  it { should have_one(:bigbluebutton_room).dependent(:destroy) }
  context 'space bigbluebutton' do
    let(:space) { FactoryGirl.create(:space_with_associations) }
    it { space.bigbluebutton_room.owner.should be(space) } # :as => :owner
  end
  it { should accept_nested_attributes_for(:bigbluebutton_room) }

  it { should have_many(:permissions) }
  it { should have_and_belong_to_many(:users) }
  it { should have_and_belong_to_many(:admins) }
  it { should have_many(:join_requests) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_length_of(:name).is_at_least(3) }

  describe "#slug" do
    it { should validate_uniqueness_of(:slug).case_insensitive }
    it { should validate_length_of(:slug).is_at_least(3) }
    it { should_not allow_value("123 321").for(:slug) }
    it { should_not allow_value("").for(:slug) }
    it { should_not allow_value("ab@c").for(:slug) }
    it { should_not allow_value("ab#c").for(:slug) }
    it { should_not allow_value("ab$c").for(:slug) }
    it { should_not allow_value("ab%c").for(:slug) }
    it { should_not allow_value("ábcd").for(:slug) }
    it { should allow_value("---").for(:slug) }
    it { should allow_value("-abc").for(:slug) }
    it { should allow_value("abc-").for(:slug) }
    it { should allow_value("_abc").for(:slug) }
    it { should allow_value("abc_").for(:slug) }
    it { should allow_value("abc").for(:slug) }
    it { should allow_value("123").for(:slug) }
    it { should allow_value("111").for(:slug) }
    it { should allow_value("aaa").for(:slug) }
    it { should allow_value("___").for(:slug) }
    it { should allow_value("abc-123_d5").for(:slug) }

    shared_examples "invalid space with slug not unique" do
      it { subject.should_not be_valid }
      it {
        subject.save.should be(false)
        subject.errors.should have_key(:slug)
        subject.errors.messages[:slug].should include(message)
      }
    end

    describe "blocks reserved words" do
      let(:message) { "has already been taken" }
      file = File.join(::Rails.root, "config", "reserved_words.yml")
      words = YAML.load_file(file)['words']

      describe "on create" do
        words.each do |word|
          context "word: #{word}" do
            subject { FactoryGirl.build(:space, slug: word) }
            include_examples "invalid space with slug not unique"
          end
        end
      end

      describe "on update" do
        words.each do |word|
          context "word: #{word}" do
            let(:subject) { FactoryGirl.create(:space) }
            before(:each) {
              subject.slug = word
            }
            include_examples "invalid space with slug not unique"
          end
        end
      end
    end

    describe "validates uniqueness against Space#slug" do
      let(:message) { "has already been taken" }

      describe "on create" do
        context "with an enabled space" do
          let(:space) { FactoryGirl.create(:space) }
          subject { FactoryGirl.build(:space, slug: space.slug) }
          include_examples "invalid space with slug not unique"
        end

        context "with a disabled space" do
          let(:disabled_space) { FactoryGirl.create(:space, disabled: true) }
          subject { FactoryGirl.build(:space, slug: disabled_space.slug) }
          include_examples "invalid space with slug not unique"
        end

        context "uses case-insensitive comparisons" do
          let!(:space) { FactoryGirl.create(:space, slug: "My-Weird-Name") }
          subject { FactoryGirl.build(:space, slug: "mY-weiRD-NAMe") }
          include_examples "invalid space with slug not unique"
        end
      end

      describe "on update" do
        context "with an enabled space" do
          let(:subject) { FactoryGirl.create(:space) }
          let(:space) { FactoryGirl.create(:space) }
          before(:each) {
            subject.slug = space.slug
          }
          include_examples "invalid space with slug not unique"
        end

        context "with a disabled space" do
          let(:subject) { FactoryGirl.create(:space) }
          let(:disabled_space) { FactoryGirl.create(:space, :disabled => true) }
          before(:each) {
            subject.slug = disabled_space.slug
          }
          include_examples "invalid space with slug not unique"
        end

        context "uses case-insensitive comparisons" do
          let(:subject) { FactoryGirl.create(:space) }
          let!(:space) { FactoryGirl.create(:space, slug: "My-Weird-Name") }
          before(:each) {
            subject.slug = "mY-weiRD-NAMe"
          }
          include_examples "invalid space with slug not unique"
        end
      end
    end

    describe "validates uniqueness against User#username" do
      let(:message) { "has already been taken" }

      describe "on create" do
        context "with an enabled user" do
          let(:user) { FactoryGirl.create(:user) }
          subject { FactoryGirl.build(:space, slug: user.username) }
          include_examples "invalid space with slug not unique"
        end

        context "with a disabled user" do
          let(:disabled_user) { FactoryGirl.create(:user, disabled: true) }
          subject { FactoryGirl.build(:space, slug: disabled_user.username) }
          include_examples "invalid space with slug not unique"
        end

        context "uses case-insensitive comparisons" do
          let!(:user) { FactoryGirl.create(:user, username: "My-Weird-Name") }
          subject { FactoryGirl.build(:space, slug: "mY-weiRD-NAMe") }
          include_examples "invalid space with slug not unique"
        end
      end

      describe "on update" do
        context "with an enabled space" do
          let(:subject) { FactoryGirl.create(:space) }
          let(:other_user) { FactoryGirl.create(:user) }
          before(:each) {
            subject.slug = other_user.username
          }
          include_examples "invalid space with slug not unique"
        end

        context "with a disabled space" do
          let(:subject) { FactoryGirl.create(:space) }
          let(:disabled_user) { FactoryGirl.create(:user, :disabled => true) }
          before(:each) {
            subject.slug = disabled_user.username
          }
          include_examples "invalid space with slug not unique"
        end

        context "uses case-insensitive comparisons" do
          let(:subject) { FactoryGirl.create(:space) }
          let!(:other_user) { FactoryGirl.create(:user, username: "My-Weird-Name") }
          before(:each) {
            subject.slug = "mY-weiRD-NAMe"
          }
          include_examples "invalid space with slug not unique"
        end
      end
    end

    context "validates against webconf room params" do
      let(:message) { "has already been taken" }

      describe "on create" do
        context "with an exact match" do
          let(:room) { FactoryGirl.create(:bigbluebutton_room) }
          subject { FactoryGirl.build(:space_with_associations, slug: room.slug) }
          include_examples "invalid space with slug not unique"
        end

        context "uses case-insensitive comparisons" do
          let!(:room) { FactoryGirl.create(:bigbluebutton_room, slug: "My-Weird-Name") }
          subject { FactoryGirl.build(:space_with_associations, slug: "mY-weiRD-NAMe") }
          include_examples "invalid space with slug not unique"
        end
      end

      describe "on update" do
        context "with an exact match" do
          let(:subject) { FactoryGirl.create(:space) }
          let(:other_room) { FactoryGirl.create(:bigbluebutton_room) }
          before(:each) {
            subject.slug = other_room.slug
          }
          include_examples "invalid space with slug not unique"
        end

        context "uses case-insensitive comparisons" do
          let(:subject) { FactoryGirl.create(:space) }
          let!(:other_room) { FactoryGirl.create(:bigbluebutton_room, slug: "My-Weird-Name") }
          before(:each) {
            subject.slug = "mY-weiRD-NAMe"
          }
          include_examples "invalid space with slug not unique"
        end

        context "doesn't validate against its own room" do
          let!(:space) { FactoryGirl.create(:space) }
          it { space.update_attributes(slug: space.slug).should be(true) }
        end
      end
    end

    describe "generates a unique slug when creating without setting a slug" do

      context "conflicting with a user" do
        let(:user) { FactoryGirl.create(:user, username: nil) }
        let(:space) {
          FactoryGirl.create(:space, slug: nil, name: user.name)
        }
        it { space.slug.should eql(user.username + "-2") }
      end

      context "conflicting with a disabled user" do
        let(:user) { FactoryGirl.create(:user, username: nil, disabled: true) }
        let(:space) {
          FactoryGirl.create(:space, slug: nil, name: user.name)
        }
        it { space.slug.should eql(user.username + "-2") }
      end

      context "conflicting with another space" do
        let(:another_space) {
          s = FactoryGirl.create(:space, slug: nil)
          s.update_attributes(name: s.name + "-other") # so it won't give a conflict on #name
          s
        }
        let(:space) {
          FactoryGirl.create(:space, slug: nil, name: another_space.slug)
        }
        it { space.slug.should eql(another_space.slug + "-2") }
      end

      context "conflicting with a disabled space" do
        let(:another_space) {
          s = FactoryGirl.create(:space, slug: nil, disabled: true)
          s.update_attributes(name: s.name + "-other") # so it won't give a conflict on #name
          s
        }
        let(:space) {
          FactoryGirl.create(:space, slug: nil, name: another_space.slug)
        }
        it { space.slug.should eql(another_space.slug + "-2") }
      end

      context "conflicting with a room" do
        let!(:user) {
          u = FactoryGirl.create(:user)
          u.bigbluebutton_room.update_attributes(slug: 'anything')
          u
        }
        let(:space) {
          FactoryGirl.create(:space, slug: nil, name: 'anything')
        }
        it { space.slug.should eql("anything-2") }
      end

      context "conflicting with a blacklisted word" do
        let(:space) {
          FactoryGirl.create(:space, slug: nil, name: 'Users')
        }
        it { space.slug.should eql("users-2") }
      end

      # TODO: if setting the slug, should not generate but show a conflict

    end
  end

  it "#check_errors_on_bigbluebutton_room"

  it { should respond_to(:invitation_ids) }
  it { should respond_to(:"invitation_ids=") }

  it { should respond_to(:invitation_mails) }
  it { should respond_to(:"invitation_mails=") }

  it { should respond_to(:invite_msg) }
  it { should respond_to(:"invite_msg=") }

  it { should respond_to(:inviter_id) }
  it { should respond_to(:"inviter_id=") }

  it { should respond_to(:invitations_role_id) }
  it { should respond_to(:"invitations_role_id=") }

  it { should respond_to(:logo_image) }
  it { should respond_to(:crop_x) }
  it { should respond_to(:"crop_x=") }
  it { should respond_to(:crop_y) }
  it { should respond_to(:"crop_y=") }
  it { should respond_to(:crop_w) }
  it { should respond_to(:"crop_w=") }
  it { should respond_to(:crop_h) }
  it { should respond_to(:"crop_h=") }
  it { should respond_to(:crop_img_w) }
  it { should respond_to(:"crop_img_w=") }
  it { should respond_to(:crop_img_h) }
  it { should respond_to(:"crop_img_h=") }

  describe "default_scope :disabled => false" do
    before {
      @s1 = FactoryGirl.create(:space, :disabled => false)
      @s2 = FactoryGirl.create(:space, :disabled => false)
      @s3 = FactoryGirl.create(:space, :disabled => true)
    }

    it { Space.count.should be 2 }
    it { Space.all.should include(@s1) }
    it { Space.all.should include(@s2) }
    it { Space.all.should_not include(@s3) }

    it { Space.unscoped.count.should be 3 }
    it { Space.unscoped.should include(@s1) }
    it { Space.unscoped.should include(@s2) }
    it { Space.unscoped.should include(@s3) }
  end

  context "on update" do
    let(:space) { FactoryGirl.create(:space) }

    it("calls #update_webconf_room") {
      space.should_receive(:update_webconf_room)
      space.update_attributes(slug: "new-slug")
    }
  end

  describe ".public_spaces" do
    before {
      @public1 = FactoryGirl.create(:public_space)
      @public2 = FactoryGirl.create(:public_space)
      another = FactoryGirl.create(:private_space)
    }
    it { Space.public_spaces.length.should be(2) }
    it { Space.public_spaces.should include(@public1) }
    it { Space.public_spaces.should include(@public2) }
  end

  describe ".order_by_activity" do
    let!(:now) { Time.now.beginning_of_day }
    let!(:spaces) do
      [
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations)
      ]
    end

    context 'for events in the space only' do
      let!(:activities) do
        [
         # order: [1], [2], [0], [3]
         RecentActivity.create(owner: spaces[0], created_at: now),
         RecentActivity.create(owner: spaces[1], created_at: now + 2.days),
         RecentActivity.create(owner: spaces[2], created_at: now + 1.day),
         RecentActivity.create(owner: spaces[3], created_at: now - 1.day)
        ]
      end
      before { Space.calculate_last_activity_indexes! }

      it { Space.order_by_activity.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_activity.all.should == [spaces[1], spaces[2], spaces[0], spaces[3]] }
    end

    context "considers events in the space's room" do
      let!(:activities) do
        [
         # order: [1], [2], [0], [3]
         RecentActivity.create(owner: spaces[0], created_at: now),
         RecentActivity.create(owner: spaces[1].bigbluebutton_room, created_at: now + 2.days),
         RecentActivity.create(owner: spaces[2].bigbluebutton_room, created_at: now + 1.day),
         RecentActivity.create(owner: spaces[3], created_at: now - 1.day)
        ]
      end
      before { Space.calculate_last_activity_indexes! }

      it { Space.order_by_activity.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_activity.all.should == [spaces[1], spaces[2], spaces[0], spaces[3]] }
    end

    context 'ignores disabled spaces' do
      let!(:activities) do
        [
         # order: [2], [0]
         # if didn't ignore disabled spaces it would be [1], [2], [0], [3]
         RecentActivity.create(owner: spaces[0], created_at: now),
         RecentActivity.create(owner: spaces[1], created_at: now + 2.days),
         RecentActivity.create(owner: spaces[2], created_at: now + 1.day),
         RecentActivity.create(owner: spaces[3], created_at: now - 1.day)
        ]
      end

      before {
        spaces[1].disable
        spaces[3].disable

        Space.calculate_last_activity_indexes!
      }
      it { Space.order_by_activity.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_activity.all.should == [spaces[2], spaces[0]] }
    end

    context 'orders secondarily by name' do
      let!(:activities) do
        [
          RecentActivity.create(owner: spaces[0], created_at: now),
          RecentActivity.create(owner: spaces[1], created_at: now),
          RecentActivity.create(owner: spaces[2], created_at: now),
          RecentActivity.create(owner: spaces[3], created_at: now)
        ]
      end
      let!(:spaces) do
        [
          FactoryGirl.create(:space_with_associations, name: "c123"),
          FactoryGirl.create(:space_with_associations, name: "D123"),
          FactoryGirl.create(:space_with_associations, name: "A123"),
          FactoryGirl.create(:space_with_associations, name: "b123")
        ]
      end
      before { Space.calculate_last_activity_indexes! }

      it { Space.order_by_activity.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_activity.all.should == [spaces[2], spaces[3], spaces[0], spaces[1]] }
    end

    context 'returns spaces even if they have no activities' do
      it { Space.order_by_activity.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_activity.all.length.should be(4) }
    end

    context 'returns spaces even if they have no room' do
      before {
        spaces.each do |space|
          space.bigbluebutton_room.destroy
        end
      }
      it { Space.order_by_activity.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_activity.all.length.should be(4) }
    end

    skip 'calling `order_by_activity.count` works'
  end

  describe ".order_by_relevance" do
    let!(:now) { Time.now.beginning_of_day }
    let!(:spaces) do
      [
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations)
      ]
    end

    context 'orders primarily by last activity' do

      context 'for events in the space only' do
        let!(:activities) do
          [
           # order: [1], [2], [0], [3]
           RecentActivity.create(owner: spaces[0], created_at: now),
           RecentActivity.create(owner: spaces[1], created_at: now + 2.days),
           RecentActivity.create(owner: spaces[2], created_at: now + 1.day),
           RecentActivity.create(owner: spaces[3], created_at: now - 1.day)
          ]
        end
        before { Space.calculate_last_activity_indexes! }

        it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
        it { Space.order_by_relevance.all.should == [spaces[1], spaces[2], spaces[0], spaces[3]] }
      end

      context "considers events in the space's room" do
        let!(:activities) do
          [
           # order: [1], [2], [0], [3]
           RecentActivity.create(owner: spaces[0], created_at: now),
           RecentActivity.create(owner: spaces[1].bigbluebutton_room, created_at: now + 2.days),
           RecentActivity.create(owner: spaces[2].bigbluebutton_room, created_at: now + 1.day),
           RecentActivity.create(owner: spaces[3], created_at: now - 1.day)
          ]
        end
        before { Space.calculate_last_activity_indexes! }

        it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
        it { Space.order_by_relevance.all.should == [spaces[1], spaces[2], spaces[0], spaces[3]] }
      end

      context 'ignores disabled spaces' do
        let!(:activities) do
          [
           # order: [2], [0]
           # if didn't ignore disabled spaces it would be [1], [2], [0], [3]
           RecentActivity.create(owner: spaces[0], created_at: now),
           RecentActivity.create(owner: spaces[1], created_at: now + 2.days),
           RecentActivity.create(owner: spaces[2], created_at: now + 1.day),
           RecentActivity.create(owner: spaces[3], created_at: now - 1.day)
          ]
        end

        before {
          spaces[1].disable
          spaces[3].disable
          Space.calculate_last_activity_indexes!
        }
        it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
        it { Space.order_by_relevance.all.should == [spaces[2], spaces[0]] }
      end
    end

    context 'orders secondarily by the number of activities' do

      context 'for events in the space only' do
        let!(:activities) do
          [
           # order: [2], [3], [0], [1]
           RecentActivity.create(owner: spaces[0], created_at: now),
           RecentActivity.create(owner: spaces[0], created_at: now),
           RecentActivity.create(owner: spaces[1], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[3], created_at: now),
           RecentActivity.create(owner: spaces[3], created_at: now),
           RecentActivity.create(owner: spaces[3], created_at: now)
          ]
        end
        before { Space.calculate_last_activity_indexes! }

        it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
        it { Space.order_by_relevance.all.should == [spaces[2], spaces[3], spaces[0], spaces[1]] }
      end

      context "considers events in the space's room" do
        let!(:activities) do
          [
           # order: [2], [3], [0], [1]
           # if it didn't consider room events it would be: [2], [1], [0], [3]
           RecentActivity.create(owner: spaces[0], created_at: now),
           RecentActivity.create(owner: spaces[0].bigbluebutton_room, created_at: now),
           RecentActivity.create(owner: spaces[1], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[2].bigbluebutton_room, created_at: now),
           RecentActivity.create(owner: spaces[2].bigbluebutton_room, created_at: now),
           RecentActivity.create(owner: spaces[3].bigbluebutton_room, created_at: now),
           RecentActivity.create(owner: spaces[3].bigbluebutton_room, created_at: now),
           RecentActivity.create(owner: spaces[3].bigbluebutton_room, created_at: now)
          ]
        end
        before { Space.calculate_last_activity_indexes! }

        it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
        it { Space.order_by_relevance.all.should == [spaces[2], spaces[3], spaces[0], spaces[1]] }
      end

      context 'ignores disabled spaces' do
        let!(:activities) do
          [
           # order: [2], [0]
           # if didn't ignore disabled spaces it would be [2], [3], [0], [1]
           RecentActivity.create(owner: spaces[0], created_at: now),
           RecentActivity.create(owner: spaces[0], created_at: now),
           RecentActivity.create(owner: spaces[1], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[2], created_at: now),
           RecentActivity.create(owner: spaces[3], created_at: now),
           RecentActivity.create(owner: spaces[3], created_at: now),
           RecentActivity.create(owner: spaces[3], created_at: now)
          ]
        end

        before {
          spaces[1].disable
          spaces[3].disable
          Space.calculate_last_activity_indexes!
        }
        it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
        it { Space.order_by_relevance.all.should == [spaces[2], spaces[0]] }
      end

      context 'considers the date only, ignores the time' do
        let!(:activities) do
          [
            # order: [0], [1], [3], [2]
            # if didn't ignore the time it would be [1], [0], [2], [3]
            RecentActivity.create(owner: spaces[0], created_at: now),
            RecentActivity.create(owner: spaces[0], created_at: now),
            RecentActivity.create(owner: spaces[1], created_at: now + 2.seconds),
            RecentActivity.create(owner: spaces[2], created_at: now - 1.day + 2.seconds),
            RecentActivity.create(owner: spaces[3], created_at: now - 1.day),
            RecentActivity.create(owner: spaces[3], created_at: now - 1.day)
          ]
        end
        before { Space.calculate_last_activity_indexes! }

        it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
        it { Space.order_by_relevance.all.should == [spaces[0], spaces[1], spaces[3], spaces[2]] }
      end
    end

    context 'orders tertiarily by name' do
      let!(:activities) do
        [
          RecentActivity.create(owner: spaces[0], created_at: now),
          RecentActivity.create(owner: spaces[1], created_at: now),
          RecentActivity.create(owner: spaces[2], created_at: now),
          RecentActivity.create(owner: spaces[3], created_at: now)
        ]
      end
      let!(:spaces) do
        [
          FactoryGirl.create(:space_with_associations, name: "c123"),
          FactoryGirl.create(:space_with_associations, name: "D123"),
          FactoryGirl.create(:space_with_associations, name: "A123"),
          FactoryGirl.create(:space_with_associations, name: "b123")
        ]
      end
      before { Space.calculate_last_activity_indexes! }

      it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_relevance.all.should == [spaces[2], spaces[3], spaces[0], spaces[1]] }
    end

    context 'returns spaces even if they have no activities' do
      it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_relevance.all.length.should be(4) }
    end

    context 'returns spaces even if they have no room' do
      before {
        spaces.each do |space|
          space.bigbluebutton_room.destroy
        end
      }
      it { Space.order_by_relevance.should be_a(ActiveRecord::Relation) }
      it { Space.order_by_relevance.all.length.should be(4) }
    end

    skip 'calling `order_by_relevance.count` works'
  end

  describe ".calculate_last_activity_indexes!" do
    let!(:now) { Time.now.beginning_of_day }
    let!(:spaces) do
      [
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations)
      ]
    end

    context "sets last_activity and last_activity_count for all spaces" do
      before {
        RecentActivity.create(owner: spaces[0], created_at: now)
        RecentActivity.create(owner: spaces[1], created_at: now + 2.days)
        RecentActivity.create(owner: spaces[1], created_at: now)
        RecentActivity.create(owner: spaces[1], created_at: now)
        RecentActivity.create(owner: spaces[2], created_at: now - 1.day)
        RecentActivity.create(owner: spaces[2], created_at: now - 2.days)
      }
      before { Space.calculate_last_activity_indexes! }
      it { spaces[0].reload.last_activity.to_date.should eql(now.to_date) }
      it { spaces[0].reload.last_activity_count.should eql(1) }
      it { spaces[1].reload.last_activity.to_date.should eql((now + 2.days).to_date) }
      it { spaces[1].reload.last_activity_count.should eql(3) }
      it { spaces[2].reload.last_activity.to_date.should eql((now - 1.day).to_date) }
      it { spaces[2].reload.last_activity_count.should eql(2) }
    end

    context "considers activities in the rooms" do
      before {
        RecentActivity.create(owner: spaces[0], created_at: now)
        RecentActivity.create(owner: spaces[1].bigbluebutton_room, created_at: now + 2.days)
        RecentActivity.create(owner: spaces[1], created_at: now)
        RecentActivity.create(owner: spaces[1].bigbluebutton_room, created_at: now)
        RecentActivity.create(owner: spaces[2].bigbluebutton_room, created_at: now - 1.day)
        RecentActivity.create(owner: spaces[2], created_at: now - 2.days)
      }
      before { Space.calculate_last_activity_indexes! }
      it { spaces[0].reload.last_activity.to_date.should eql(now.to_date) }
      it { spaces[0].reload.last_activity_count.should eql(1) }
      it { spaces[1].reload.last_activity.to_date.should eql((now + 2.days).to_date) }
      it { spaces[1].reload.last_activity_count.should eql(3) }
      it { spaces[2].reload.last_activity.to_date.should eql((now - 1.day).to_date) }
      it { spaces[2].reload.last_activity_count.should eql(2) }
    end

    context "maximum precision is 'day'" do
      before {
        RecentActivity.create(owner: spaces[0], created_at: now)
        RecentActivity.create(owner: spaces[0], created_at: now + 1.second)
        RecentActivity.create(owner: spaces[1], created_at: now)
        RecentActivity.create(owner: spaces[1], created_at: now + 1.minute)
        RecentActivity.create(owner: spaces[2], created_at: now)
        RecentActivity.create(owner: spaces[2], created_at: now + 1.hour)
      }
      before { Space.calculate_last_activity_indexes! }
      it { spaces[0].reload.last_activity.to_date.should eql(now.to_date) }
      it { spaces[1].reload.last_activity.to_date.should eql(now.to_date) }
      it { spaces[2].reload.last_activity.to_date.should eql(now.to_date) }
    end
  end

  describe ".logo_image" do
    let!(:logo) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test-logo.png'))) }
    let!(:crop_params) { { :crop_x => 0, :crop_y => 0, :crop_w => 10, :crop_h => 10, :crop_img_w => 350, :crop_img_h => 350 } }

    context "uploader properties" do
      let(:space) { Space.new }
      let!(:store_dir) { File.join(Rails.root, 'spec/support/uploads/space/logo_image') }

      it { space.logo_image.filename.should_not be_present }
      it { space.logo_image.extension_white_list.should eq(["jpg", "jpeg", "png", "svg", "tif", "gif"]) }
      it { space.logo_image.versions.count.should eq(7) }
      it { space.logo_image.store_dir.should eq("#{store_dir}/#{space.id}") }
      it { space.logo_image.versions.map{|v| v[0]}.should eq([:large, :logo32, :logo128, :logo300, :logo84x64, :logo168x128, :logo336x256]) }
    end

    context "crop_logo" do
      context "is called after_create" do
        let(:space) { Space.new(space_attr) }

        context "with valid params" do
          let(:space_attr) { FactoryGirl.attributes_for(:space, :logo_image => logo).merge(crop_params) }

          before do
            space.logo_image.should_receive(:recreate_versions!)
            space.save!
          end

          it { space.logo_image.should be_present }
        end

        context "without file but valid crop params" do
          let(:space_attr) { FactoryGirl.attributes_for(:space, :logo_image => nil).merge(crop_params) }

          before(:each) do
            space.logo_image.should_not_receive(:recreate_versions!)
            space.save!
          end

          it { space.logo_image.should_not be_present }
        end

        context "with file but invalid crop params" do
          let(:space_attr) { FactoryGirl.attributes_for(:space, :logo_image => logo) }

          before(:each) do
            space.logo_image.should_not_receive(:recreate_versions!)
            space.save!
          end

          it { space.logo_image.should be_present }
        end
      end

      context "is called after_update" do
        let(:space) { FactoryGirl.create(:space) }

        context "with valid params" do
          let(:space_attr) { {:logo_image => logo}.merge(crop_params) }

          before do
            space.logo_image.should_receive(:recreate_versions!)
            space.update_attributes(space_attr)
          end

          it { space.logo_image.should be_present }
        end

        context "without file but valid crop params" do
          let(:space_attr) { {:logo_image => nil}.merge(crop_params) }

          before(:each) do
            space.logo_image.should_not_receive(:recreate_versions!)
            space.update_attributes(space_attr)
          end

          it { space.logo_image.should_not be_present }
        end

        context "with file but invalid crop params" do
          let(:space_attr) { {:logo_image => logo} }

          before(:each) do
            space.logo_image.should_not_receive(:recreate_versions!)
            space.update_attributes(space_attr)
          end

          it { space.logo_image.should be_present }
        end
      end
    end

  end

  describe "::USER_ROLES" do
    it { Space::USER_ROLES.length.should be(2) }
    it { Space::USER_ROLES.should include("Admin") }
    it { Space::USER_ROLES.should include("User") }
  end

  describe "#upcoming_events" do
    context "returns the n upcoming events" do
      before {
        e1 = FactoryGirl.create(:event, :time_zone => Time.zone.name, :owner => space,
          :start_on => Time.zone.now - 5.hours, :end_on => Time.zone.now - 4.hours)
        e2 = FactoryGirl.create(:event, :owner => space, :time_zone => e1.time_zone,
          :start_on => Time.zone.now + 2.hour, :end_on => Time.zone.now + 3.hours)
        e3 = FactoryGirl.create(:event, :owner => space, :time_zone => e1.time_zone,
          :start_on => Time.zone.now + 3.hour, :end_on => Time.zone.now + 4.hours)
        e4 = FactoryGirl.create(:event, :owner => space, :time_zone => e1.time_zone,
          :start_on => Time.zone.now + 1.hour, :end_on => Time.zone.now + 2.hours)
        @expected = [e4, e2, e3]
      }
      it { space.upcoming_events(3).should eq(@expected) }
    end

    context "defaults to 5 events" do
      before {
        6.times { FactoryGirl.create(:event, :owner => space, :time_zone => Time.zone.name, :start_on => Time.zone.now + 1.hour, :end_on => Time.zone.now + 2.hours) }
      }
      it { space.upcoming_events.length.should be(5) }
    end
  end

  it "#latest_posts"

  it "#latest_users"

  describe "#permissions_ordered_by_name" do
    let(:target) { FactoryGirl.create(:space) }
    let!(:admin_role) { Role.find_by(:name => 'Admin') }
    let!(:user_role) { Role.find_by(:name => 'User') }

    before {
      user1 = FactoryGirl.create(:user, profile: FactoryGirl.create(:profile, full_name: "b123"))
      user2 = FactoryGirl.create(:user, profile: FactoryGirl.create(:profile, full_name: "c123"))
      user3 = FactoryGirl.create(:user, profile: FactoryGirl.create(:profile, full_name: "a123"))
      @permission1 = Permission.create(user: user1, role: admin_role, subject: target)
      @permission2 = Permission.create(user: user2, role: user_role, subject: target)
      @permission3 = Permission.create(user: user3, role: user_role, subject: target)
    }

    subject { target.permissions_ordered_by_name }

    it { subject.should be_a(ActiveRecord::Relation) }
    it { subject.count.should eql(3) }
    it { subject.should include(@permission1) }
    it { subject.should include(@permission2) }
    it { subject.should include(@permission3) }

    it "orders by full_name ASC" do
      subject.all[0].should eql(@permission3)
      subject.all[1].should eql(@permission1)
      subject.all[2].should eql(@permission2)
    end
  end

  describe "#add_member!" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }
    let!(:user_role) { Role.find_by(:name => 'User') }
    let!(:admin_role) { Role.find_by(:name => 'Admin') }

    context "adds the user as a member with the selected role" do
      before {
        expect {
          if selected_role
            space.add_member!(user, selected_role)
          else
            space.add_member!(user)
          end
        }.to change(space.users, :count).by(1)
      }

      context 'with role User' do
        let(:selected_role) { 'User' }

        it { space.users.should include(user) }
        it { space.permissions.last.user.should eq(user) }
        it { space.permissions.last.role.should eq(user_role) }
        it { space.role_for?(user, :name => 'User').should be true }
        it { space.role_for?(user, :name => 'Admin').should be false }
      end

      context 'with role Admin' do
        let(:selected_role) { 'Admin' }

        it { space.users.should include(user) }
        it { space.permissions.last.user.should eq(user) }
        it { space.permissions.last.role.should eq(admin_role) }
        it { space.role_for?(user, :name => 'User').should be false }
        it { space.role_for?(user, :name => 'Admin').should be true }
      end

      context "defaults the role to 'User'" do
        let(:selected_role) { nil }

        it { space.users.should include(user) }
        it { space.permissions.last.user.should eq(user) }
        it { space.permissions.last.role.should eq(user_role) }
        it { space.role_for?(user, :name => 'User').should be true }
        it { space.role_for?(user, :name => 'Admin').should be false }
      end
    end

    context "doesn't add the user if he's already a member" do
      let!(:permission) { Permission.create(:user => user, :role => user_role, :subject => space) }

      before {
        expect {
          space.add_member!(user)
        }.to raise_error(ActiveRecord::RecordInvalid)
      }

      it { space.users.should include(user) }
      it { space.permissions.last.user.should eq(user) }
    end
  end

  describe "#remove_member!" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }

    context "when the user is a member" do
      before { space.add_member!(user) }
      it { space.users.should include(user) }

      context "removes the user from the space" do
        before {
          @response = space.remove_member!(user)
        }
        it { @response.should be(true) }
        it { space.users.should_not include(user) }
        it { Permission.where(user: user, subject: space).should be_empty }
        it { space.role_for?(user, name: 'User').should be false }
        it { space.role_for?(user, name: 'Admin').should be false }
      end

      context "when it fails to remove the user" do
        before {
          ActiveRecord::Relation.any_instance.should_receive(:destroy_all).and_return([])
          @response = space.remove_member!(user)
        }
        it { @response.should be(false) }
      end

      context "doesn't remove other users" do
        before {
          space.add_member!(FactoryGirl.create(:user))
          space.add_member!(FactoryGirl.create(:user))
          space.remove_member!(user)
        }
        it { space.users.should_not include(user) }
        it { space.users.count.should eql(2) }
      end
    end

    context "if the user is not a member" do
      before {
        @response = space.remove_member!(user)
      }
      it { space.users.should_not include(user) }
      it { @response.should be(true) }
    end
  end

  it "new_activity"

  describe ".with_disabled" do
    let(:space1) { FactoryGirl.create(:space, disabled: true) }
    let(:space2) { FactoryGirl.create(:space, disabled: false) }

    context "finds spaces that are disabled" do
      subject { Space.with_disabled.all }
      it { should include(space1) }
      it { should include(space2) }
    end

    context "returns a Relation object" do
      it { Space.with_disabled.should be_kind_of(ActiveRecord::Relation) }
    end

    context "doesn't remove previous scopes from the query" do
      let(:space1) { FactoryGirl.create(:space, disabled: true, public: true) }
      let(:space2) { FactoryGirl.create(:space, disabled: true, public: false) }

      subject { Space.where(public: true).with_disabled.all }
      it { should include(space1) }
      it { should_not include(space2) }
    end

    context "is chainable" do
      let!(:space1) { FactoryGirl.create(:space, public: true, name: "abc") }
      let!(:space2) { FactoryGirl.create(:space, public: true, name: "def") }
      let!(:space3) { FactoryGirl.create(:space, public: false, name: "abc-2") }
      let!(:space4) { FactoryGirl.create(:space, public: false, name: "def-2") }
      subject { Space.where(public: true).with_disabled.where('spaces.name LIKE ?', '%abc%') }
      it { subject.count.should eq(1) }
    end
  end

  describe "#create_webconf_room" do
    let(:space) { FactoryGirl.create(:space_with_associations) }

    it "is called when the space is created" do
      space.bigbluebutton_room.should_not be_nil
      space.bigbluebutton_room.should be_kind_of(BigbluebuttonRoom)
    end

    context "creates #bigbluebutton_room" do

      it "with the space as owner" do
        space.bigbluebutton_room.owner.should be(space)
      end

      it "with slug and name equal the space's slug" do
        space.bigbluebutton_room.slug.should eql(space.slug)
        space.bigbluebutton_room.name.should eql(space.name)
      end

      it "with the default logout url" do
        space.bigbluebutton_room.logout_url.should eql("/feedback/webconf/")
      end

      context "as public if the space is public" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
        it { space.bigbluebutton_room.private.should be false }
      end

      # changed due to feature #1481
      context "also as public if the space is private" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: false) }
        it { space.bigbluebutton_room.private.should be false }
      end

      skip "with the server as the first server existent"
    end
  end

  describe "#update_webconf_room" do
    let(:space) { FactoryGirl.create(:space_with_associations) }

    context "updates the name" do
      let(:space) { FactoryGirl.create(:space_with_associations, name: "Old Name") }
      before(:each) { space.update_attributes(name: "New Name") }
      it { space.name.should eql("New Name") }
      it { space.bigbluebutton_room.name.should eql("New Name") }
    end

    context "doesn't update the name if the name was already changed directly before" do
      let(:space) { FactoryGirl.create(:space_with_associations, name: "Old Name") }
      before(:each) {
        space.bigbluebutton_room.update_attributes(name: "Custom Room Name")
        space.update_attributes(name: "New Name")
      }
      it { space.name.should eql("New Name") }
      it { space.bigbluebutton_room.name.should eql("Custom Room Name") }
    end

    context "updates the slug" do
      let(:space) { FactoryGirl.create(:space_with_associations, slug: "old-slug") }
      before(:each) { space.update_attributes(slug: "new-slug") }
      it { space.slug.should eql("new-slug") }
      it { space.bigbluebutton_room.slug.should eql("new-slug") }
    end

    context "updates the slug even if it was already changed directly before" do
      let(:space) { FactoryGirl.create(:space_with_associations, slug: "old-slug") }
      before(:each) {
        space.bigbluebutton_room.update_attributes(slug: "custom-slug")
        space.update_attributes(slug: "new-slug")
      }
      it { space.slug.should eql("new-slug") }
      it { space.bigbluebutton_room.slug.should eql("new-slug") }
    end

    # Space visibility is not linked to webconf visibility anymore
    # see feature #1436
    context "doesn't update to public when the space is made public" do
      before {
        space.bigbluebutton_room.update_attribute(:private, true)
        space.update_attribute(:public, true)
      }

      it { space.bigbluebutton_room.private.should be(true) }
    end

    # see feature #1436
    context "doesn't update to private when the space is made public" do
      before {
        space.bigbluebutton_room.update_attribute(:private, false)
        space.update_attribute(:public, false)
      }

      it { space.bigbluebutton_room.private.should be(false) }
    end
  end

  describe "user associations" do
    before {
      @users = []
      0.upto(3) { @users << FactoryGirl.create(:user) }
      space.add_member!(@users[0], "Admin")
      space.add_member!(@users[1], "Admin")
      space.add_member!(@users[2], "User")
    }

    describe "#permissions" do
      it { space.permissions.klass == Permission }
      it { space.permissions.length.should be(3) }
      it { space.permissions.should include(*Permission.where(:user_id => @users)) }
    end

    describe "#admins" do
      context "returns the admins of the space" do
        it { space.admins.klass == User }
        it { space.admins.length.should be(2) }
        it { space.admins.should include(@users[0]) }
        it { space.admins.should include(@users[1]) }
      end
    end

    describe "#users" do
      context "returns the users of the space" do
        it { space.users.klass == User }
        it { space.users.length.should be(3) }
        it { space.users.should include(@users[0]) }
        it { space.users.should include(@users[1]) }
        it { space.users.should include(@users[2]) }
      end
    end

  end

  describe "join requests" do
    before {
      @jr = [
        FactoryGirl.create(:join_request, :group => space, :request_type => JoinRequest::TYPES[:request]),
        FactoryGirl.create(:join_request, :group => space, :request_type => JoinRequest::TYPES[:request]),
        FactoryGirl.create(:join_request, :group => space, :request_type => JoinRequest::TYPES[:invite])
      ]
      @invitations = [@jr[2]]
      @requests = [@jr[0], @jr[1]]
    }

    describe "#join_requests" do
      it { space.join_requests.should include(*@jr) }
      it { space.join_requests.length.should be(3) }
      it { space.join_requests.should include(*[@invitations, @requests].flatten) }
    end

    describe "#pending_join_requests" do
      it { space.pending_join_requests.klass == JoinRequest }
      it { space.pending_join_requests.length.should be(2) }
      it { space.pending_join_requests.should include(*@requests) }
    end

    describe "#pending_invitations" do
      it { space.pending_invitations.klass == JoinRequest }
      it { space.pending_invitations.length.should be(1) }
      it { space.pending_invitations.should include(*@invitations) }
    end

    describe "#pending_join_request_for(?)" do
      let(:user) { @requests.first.candidate }
      let(:other_user) { FactoryGirl.create(:user) }

      it { space.pending_join_request_for(user).should eq(@requests.first) }
      it { space.pending_join_request_for(other_user).should be_blank }
      it { space.pending_join_request_for?(user).should be true }
      it { space.pending_join_request_for?(other_user).should be false }
    end

    describe "#pending_invitation_for(?)" do
      let(:user) { @invitations.first.candidate }
      let(:other_user) { FactoryGirl.create(:user) }

      it { space.pending_invitation_for(user).should eq(@invitations.first) }
      it { space.pending_invitation_for(other_user).should be_blank }
      it { space.pending_invitation_for?(user).should be true }
      it { space.pending_invitation_for?(other_user).should be false }
    end

  end

  describe "#enabled?" do
    let(:space) { FactoryGirl.create(:space) }

    context "if the space is not disabled" do
      it { space.enabled?.should be(true) }
      it { space.disabled?.should be(false) }
    end

    context "if the space is disabled" do
      before { space.disable }
      it { space.enabled?.should be(false) }
      it { space.disabled?.should be(true) }
    end
  end

  describe ".search_by_terms" do
    it "includes disabled spaces"
    it "searches by name"
    it "searches by description"
    it "searches by name and description"
    it "searches with multiple words"
  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:leave, :enable, :webconference, :select, :disable, :update_logo,
      :user_permissions, :edit_recording, :webconference_options, :meetings,
      :manage_join_requests, :add, :index_event])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    context "a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }

        context "he is not a member of" do
          it { should be_able_to_do_everything_to(target).except(:leave) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }

            context "being the last admin" do
              it { should be_able_to_do_everything_to(target).except(:leave) }
            end

            context "when there's another admin" do
              before { target.add_member!(FactoryGirl.create(:user), "Admin") }
              it { should be_able_to_do_everything_to(target) }
            end
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should be_able_to_do_everything_to(target) }
          end
        end

        context "that is disabled" do
          before { target.disable }
          it { should be_able_to_do_everything_to(target).except(:leave) }
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }

        context "he is not a member of" do
          it { should be_able_to_do_everything_to(target).except(:leave) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should be_able_to_do_everything_to(target).except(:leave) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should be_able_to_do_everything_to(target) }
          end
        end

        context "that is disabled" do
          before { target.disable }
          it { should be_able_to_do_everything_to(target).except(:leave) }
        end
      end

      context "if the creation of spaces is" do
        context "disabled" do
          before { Site.current.update_attributes(forbid_user_space_creation: true) }
          it { should be_able_to(:create, Space) }
          it { should be_able_to(:new, Space) }
        end

        context "enabled" do
          before { Site.current.update_attributes(forbid_user_space_creation: false) }
          it { should be_able_to(:create, Space) }
          it { should be_able_to(:new, Space) }
        end
      end
    end

    context "a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except([:show, :index, :webconference, :meetings, :create, :new, :select, :index_event]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            context "being the last admin" do
              it {
                list = [
                  :show, :index, :webconference, :meetings, :create, :new, :select, :edit,
                  :update, :update_logo, :disable, :user_permissions, :edit_recording,
                  :webconference_options, :manage_join_requests, :index_event
                ]
                should_not be_able_to_do_anything_to(target).except(list)
              }
            end

            context "when there's another admin" do
              before { target.add_member!(FactoryGirl.create(:user), "Admin") }
              it {
                list = [
                  :show, :index, :webconference, :meetings, :create, :new, :select, :leave, :edit,
                  :update, :update_logo, :disable, :user_permissions, :edit_recording,
                  :webconference_options, :manage_join_requests, :index_event
                ]
                should_not be_able_to_do_anything_to(target).except(list)
              }
            end

            context "when the space is not approved" do
              before { target.update_attributes(approved: false) }
              it {
                list = [
                  :show, :index, :create, :new, :select, :edit,
                  :update, :update_logo, :disable
                ]
                should_not be_able_to_do_anything_to(target).except(list)
              }
            end
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it {
              should_not be_able_to_do_anything_to(target)
                .except([:show, :index, :webconference, :meetings, :create, :new, :select, :leave, :index_event])
            }

            context "when the space is not approved" do
              before { target.update_attributes(approved: false) }
              it { should_not be_able_to_do_anything_to(target).except([:index, :create, :new, :select]) }
            end
          end
        end

        context "that is disabled" do
          before { target.disable }
          it { should_not be_able_to_do_anything_to(target) }
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except([:create, :new, :select, :index]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            context "being the last admin" do
              it {
                list = [
                  :show, :index, :webconference, :meetings, :create, :new, :select, :edit,
                  :update, :update_logo, :disable, :user_permissions, :edit_recording,
                  :webconference_options, :manage_join_requests, :index_event
                ]
                should_not be_able_to_do_anything_to(target).except(list)
              }
            end

            context "when there's another admin" do
              before { target.add_member!(FactoryGirl.create(:user), "Admin") }
              it {
                list = [
                  :show, :index, :webconference, :meetings, :create, :new, :select, :leave, :edit,
                  :update, :update_logo, :disable, :user_permissions, :edit_recording,
                  :webconference_options, :manage_join_requests, :index_event
                ]
                should_not be_able_to_do_anything_to(target).except(list)
              }
            end

            context "when the space is not approved" do
              before { target.update_attributes(approved: false) }
              it {
                list = [
                  :show, :index, :create, :new, :select, :edit,
                  :update, :update_logo, :disable,
                ]
                should_not be_able_to_do_anything_to(target).except(list)
              }
            end
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it {
              should_not be_able_to_do_anything_to(target)
                .except([:show, :index, :webconference, :meetings, :create, :new, :select, :leave, :index_event])
            }

            context "when the space is not approved" do
              before { target.update_attributes(approved: false) }
              it { should_not be_able_to_do_anything_to(target).except([:create, :new, :select, :index]) }
            end
          end
        end

        context "that is disabled" do
          before { target.disable }
          it { should_not be_able_to_do_anything_to(target) }
        end
      end

      context "if the creation of spaces is" do
        context "disabled" do
          before { Site.current.update_attributes(forbid_user_space_creation: true) }
          it { should_not be_able_to(:create, Space) }
          it { should_not be_able_to(:new, Space) }
        end

        context "enabled" do
          before { Site.current.update_attributes(forbid_user_space_creation: false) }
          it { should be_able_to(:create, Space) }
          it { should be_able_to(:new, Space) }
        end
      end
    end

    context "an anonymous user", :user => "anonymous" do
      let(:user) { User.new }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }
        it { should_not be_able_to_do_anything_to(target).except([:show, :index, :webconference, :meetings, :select, :index_event]) }

        context "that is disabled" do
          before { target.disable }
          it { should_not be_able_to_do_anything_to(target) }
        end

        context "when the space is not approved" do
          before { target.update_attributes(approved: false) }
          it { should_not be_able_to_do_anything_to(target).except([:select, :index]) }
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }
        it { should_not be_able_to_do_anything_to(target).except([:select, :index]) }

        context "that is disabled" do
          before { target.disable }
          it { should_not be_able_to_do_anything_to(target) }
        end

        context "when the space is not approved" do
          before { target.update_attributes(approved: false) }
          it { should_not be_able_to_do_anything_to(target).except([:select, :index]) }
        end
      end

      context "if the creation of spaces is" do
        context "disabled" do
          before { Site.current.update_attributes(forbid_user_space_creation: true) }
          it { should_not be_able_to(:create, Space) }
          it { should_not be_able_to(:new, Space) }
        end

        context "enabled" do
          before { Site.current.update_attributes(forbid_user_space_creation: false) }
          it { should_not be_able_to(:create, Space) }
          it { should_not be_able_to(:new, Space) }
        end
      end
    end

  end
end
