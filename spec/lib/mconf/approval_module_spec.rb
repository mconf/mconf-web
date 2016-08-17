# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::ApprovalModule do

  describe '.included' do
    it "sets a before_create filter to automatically approve the resource"
  end

  describe '#automatically_approve' do
    it "sets #approved to true"
  end

  describe '#create_approval_notification' do
    it "creates the recent activity correctly"
  end

  describe '#approve!' do
    it "sets #approved to true and saves"
  end

  describe '#disapprove!' do
    it "sets #approved to false and saves"
  end

  describe '#needs_approval?' do
    it "always false"
  end

end
