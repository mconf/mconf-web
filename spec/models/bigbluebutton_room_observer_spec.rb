# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonRoomObserver do

  context "after_create" do
    let(:params) { FactoryGirl.attributes_for(:bigbluebutton_room) }
    before(:each) { BigbluebuttonRoom.create(params) }

    context "creating metadata" do
      context "creates 'title' if it doesn't exist yet" do
        let(:name) { "mconfweb-title" }
        before(:each) { @metas = BigbluebuttonRoom.last.metadata.where(:name => name) }
        it { @metas.count.should be(1) }
        it { @metas.first.name.should eq(name) }
        it { @metas.first.content.should be_nil }
      end

      context "creates 'description' if it doesn't exist yet" do
        let(:name) { "mconfweb-description" }
        before(:each) { @metas = BigbluebuttonRoom.last.metadata.where(:name => name) }
        it { @metas.count.should be(1) }
        it { @metas.first.name.should eq(name) }
        it { @metas.first.content.should be_nil }
      end
    end
  end

  context "after_update" do
    let(:params) { FactoryGirl.attributes_for(:bigbluebutton_room) }
    let(:room) { BigbluebuttonRoom.create(params) }

    context "creating metadata" do

      context "creates 'title' if it doesn't exist yet" do
        let(:name) { "mconfweb-title" }
        before(:each) {
          room.metadata.where(:name => name).first.destroy
          room.metadata.where(:name => name).should be_empty
          room.update_attributes(:private => !room.private) # anything, just to trigger the observer
          @metas = room.metadata.where(:name => name)
        }
        it { @metas.count.should be(1) }
        it { @metas.first.name.should eq(name) }
        it { @metas.first.content.should be_nil }
      end

      context "doesn't create 'title' if it already exists" do
        let(:name) { "mconfweb-title" }
        before(:each) {
          room.metadata.where(:name => name).should_not be_empty
          @content = room.metadata.where(:name => name).first.content
          room.update_attributes(:private => !room.private) # anything, just to trigger the observer
          @metas = room.metadata.where(:name => name)
        }
        it { @metas.count.should be(1) }
        it { @metas.first.name.should eq(name) }
        it { @metas.first.content.should be(@content) }
      end

      context "creates 'description' if it doesn't exist yet" do
        let(:name) { "mconfweb-description" }
        before(:each) {
          room.metadata.where(:name => name).first.destroy
          room.metadata.where(:name => name).should be_empty
          room.update_attributes(:private => !room.private) # anything, just to trigger the observer
          @metas = room.metadata.where(:name => name)
        }
        it { @metas.count.should be(1) }
        it { @metas.first.name.should eq(name) }
        it { @metas.first.content.should be_nil }
      end

      context "doesn't create 'description' if it already exists" do
        let(:name) { "mconfweb-description" }
        before(:each) {
          room.metadata.where(:name => name).should_not be_empty
          @content = room.metadata.where(:name => name).first.content
          room.update_attributes(:private => !room.private) # anything, just to trigger the observer
          @metas = room.metadata.where(:name => name)
        }
        it { @metas.count.should be(1) }
        it { @metas.first.name.should eq(name) }
        it { @metas.first.content.should be(@content) }
      end

    end
  end

end
