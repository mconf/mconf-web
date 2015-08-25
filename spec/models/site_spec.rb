# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Site do

  describe "#allow_to_record_string" do

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
        site.update_attribute :allow_to_record, ["teste", "teste2", "teste3"]
      }
      it { site.allow_to_record_string.should eql("teste\nteste2\nteste3") }
    end
  end

  describe "#allow_to_record=" do

    context "if the param passed is a String, allow_to_record should be written as an array" do
      let(:site) { FactoryGirl.create(:site) }
      before {
        site.allow_to_record = "Docente,\nProfessor visitante,\nteste"
      }
      it { site.allow_to_record.should eql(["Docente", "Professor visitante", "teste"]) }
    end

    context "if the param passed is an empty string, allow_to_record should be an empty array" do
      let(:site) { FactoryGirl.create(:site) }
      before {
        site.allow_to_record = ""
      }
      it { site.allow_to_record.should eql([]) }
    end

  end
end
