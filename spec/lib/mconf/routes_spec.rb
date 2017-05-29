# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::Routes do

  describe '.reserved_names' do
    before {
      Mconf::Application.routes.draw do
        get '/admin', to: 'sessions#new'
        get '/spaces', to: 'spaces#index'
        get '/spaces/select', to: 'spaces#select'
        get '/spaces/meetings', to: 'spaces#meetings'
        get '/spaces/meetings/other', to: 'spaces#meetings'
      end
    }
    after {
      Rails.application.reload_routes!
    }

    context "with no scope" do
      subject { Mconf::Routes.reserved_names }
      it { subject.count.should eql(3) }
      it { subject.should include('assets') }
      it { subject.should include('admin') }
      it { subject.should include('spaces') }
    end

    context "with an empty scope" do
      subject { Mconf::Routes.reserved_names('') }
      it { subject.count.should eql(3) }
      it { subject.should include('assets') }
      it { subject.should include('admin') }
      it { subject.should include('spaces') }
    end

    context "with the scope '/'" do
      subject { Mconf::Routes.reserved_names('/') }
      it { subject.count.should eql(3) }
      it { subject.should include('assets') }
      it { subject.should include('admin') }
      it { subject.should include('spaces') }
    end

    context "with a scope" do
      subject { Mconf::Routes.reserved_names('/spaces') }
      it { subject.count.should eql(2) }
      it { subject.should include('select') }
      it { subject.should include('meetings') }
    end
  end
end
