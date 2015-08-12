# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Site do
  
  describe ".allow_to_record_string" do
    
    context "allow_to_record is an empty array" do
      let(:site) { FactoryGirl.create(:site) }
      before {
        site.update_attribute :allow_to_record, []
      }
      it { site.allow_to_record_string.should eql("") }
    end
    
    context "allow_to_record is not an empty array" do
      let(:site) { FactoryGirl.create(:site) }
      before {
        site.update_attribute :allow_to_record, ["teste", "teste", "teste"]
      }
      it { site.allow_to_record_string.should be_a(String) }
    end
  end

  describe ".allow_to_record=r" do

    context "if r is a String, allow_to_record should be written as an array" do
      let(:site) { FactoryGirl.create(:site) }
      before {
        site.allow_to_record = "Docente, Professor visitante, teste"
      }
      it { site.allow_to_record.should be_a(Array) }
    end
  end
end
