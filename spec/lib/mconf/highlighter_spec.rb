# coding: utf-8
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2016 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::Highlighter do
  subject { Mconf::Highlighter }

  context "#highlight_word" do
    it { subject.highlight_word("", "achei!").should_not be_nil }
    it { subject.highlight_word("", "achei!").should eq('') }
    it { subject.highlight_word("anything not matched", "found!").should eq("anything not matched") }

    context "highlight all the words found" do
      it { subject.highlight_word("", "").should eq('')}
      it { subject.highlight_word("oi", "oi").should eq('<mark>oi</mark>') }
      it { subject.highlight_word("oi oi", "oi").should eq('<mark>oi</mark> <mark>oi</mark>') }
      it { subject.highlight_word("admin admin", "admin").should eq('<mark>admin</mark> <mark>admin</mark>') }
      it { subject.highlight_word("mark mark mark", "mark").should eq('<mark>mark</mark> <mark>mark</mark> <mark>mark</mark>') }
      it { subject.highlight_word("found!", "").should eq("found!") }
      it { subject.highlight_word("áchadoñ o cachorro", "áchadoñ").should eq('<mark>áchadoñ</mark> o cachorro') }
      it { subject.highlight_word("como se fala sópa?", "como").should eq("<mark>como</mark> se fala sópa?") }
      it { subject.highlight_word("atirei no pescador", "atirei ").should eq("<mark>atirei </mark>no pescador") }
    end

    context "ignores accents" do
      it { subject.highlight_word("oì", "ói").should eq('<mark>oì</mark>') }
      it { subject.highlight_word("oi õi ôî", "ói").should eq('<mark>oi</mark> <mark>õi</mark> <mark>ôî</mark>') }
      it { subject.highlight_word("áchadoñ o cachorro", "achadon").should eq('<mark>áchadoñ</mark> o cachorro') }
      it { subject.highlight_word("Jürgen", "Jurgen").should eq('<mark>Jürgen</mark>') }

      # TODO: these two could also ignore the accents on 'ṕ' and 'ǹ'
      it { subject.highlight_word("<scríPT> alert() </SCrîṕt>", "script").should eq('<<mark>scríPT</mark>> alert() </SCrîṕt>') }
      it { subject.highlight_word("admin ÁDmĩǹ", "admin").should eq('<mark>admin</mark> ÁDmĩǹ') }
    end

    context "ignores case" do
      it { subject.highlight_word("oI õi OI", "oi").should eq('<mark>oI</mark> <mark>õi</mark> <mark>OI</mark>') }
      it { subject.highlight_word("Atiramos no Átila", "átila").should eq("Atiramos no <mark>Átila</mark>") }
      it { subject.highlight_word("Atiramos no átila", "Átila").should eq("Atiramos no <mark>átila</mark>") }
    end
  end

  context "#highlight" do
    context "for a single word" do
      it { subject.highlight("oi oi oi", "oi").should eq('<mark>oi</mark> <mark>oi</mark> <mark>oi</mark>') }
      it { subject.highlight("oi OI oI", "Oi").should eq('<mark>oi</mark> <mark>OI</mark> <mark>oI</mark>') }
      it { subject.highlight("ôî õi ói", "oì").should eq('<mark>ôî</mark> <mark>õi</mark> <mark>ói</mark>') }
      it { subject.highlight("Mark waldberg é um idiota", "mark").should eq("<mark>Mark</mark> waldberg é um idiota") }
      it { subject.highlight("Mark waldberg é um idiota, mark idiota!", "mark").should eq("<mark>Mark</mark> waldberg é um idiota, <mark>mark</mark> idiota!") }
      it { subject.highlight("Mark waldberg é um idiota", "idiota").should eq("Mark waldberg é um <mark>idiota</mark>") }
      it { subject.highlight("Mark waldberg é um idiota, mark idiota!", "idiota").should eq("Mark waldberg é um <mark>idiota</mark>, mark <mark>idiota</mark>!") }
    end

    context "for multiple words" do
      it { subject.highlight("atirei no pescador", ["atirei", "pescador"]).should eq("<mark>atirei</mark> no <mark>pescador</mark>") }
      it { subject.highlight("Mark waldberg é um idiota", ["idiota", "mark"]).should eq("<mark>Mark</mark> waldberg é um <mark>idiota</mark>") }
      it { subject.highlight("Mark waldberg é um idiota, mark idiota!", ["idiota", "mark"]).should eq("<mark>Mark</mark> waldberg é um <mark>idiota</mark>, <mark>mark</mark> <mark>idiota</mark>!") }
      it { subject.highlight("Mark waldberg é um idiota", ["mark", "idiota"]).should eq("<mark>Mark</mark> waldberg é um <mark>idiota</mark>") }
      it { subject.highlight("Mark waldberg é um idiota, mark idiota!", ["mark", "idiota"]).should eq("<mark>Mark</mark> waldberg é um <mark>idiota</mark>, <mark>mark</mark> <mark>idiota</mark>!") }
      it { subject.highlight("Mark mata cachorrinhos inocentes", ["cachorrinhos", "cachorros"]).should eq("Mark mata <mark>cachorrinhos</mark> inocentes") }
    end
  end
end
