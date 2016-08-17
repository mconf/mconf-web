# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Simple model to validate the feedback form from FeedbackController

class Feedback
  include ActiveModel::Validations
  attr_accessor :subject, :from, :message

  validates :subject, :presence => true
  validates :message, :presence => true
  validates :from, :presence => true, :email => true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end