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
      it { subject.highlight_word("<mark>rafael", "rafael").should eq("&lt;mark&gt;<mark>rafael</mark>") }
      it { subject.highlight_word("<mark>rafael1", "rafael").should eq("&lt;mark&gt;<mark>rafael</mark>1") }
      it { subject.highlight_word("1<mark>rafael", "rafael").should eq("1&lt;mark&gt;<mark>rafael</mark>") }
      it { subject.highlight_word("rafael</mark>", "rafael").should eq("<mark>rafael</mark>&lt;/mark&gt;") }
      it { subject.highlight_word("1rafael</mark>", "rafael").should eq("1<mark>rafael</mark>&lt;/mark&gt;") }
      it { subject.highlight_word("rafael</mark>1", "rafael").should eq("<mark>rafael</mark>&lt;/mark&gt;1") }
    end

    context "ignores accents" do
      it { subject.highlight_word("oì", "ói").should eq('<mark>oì</mark>') }
      it { subject.highlight_word("oi õi ôî", "ói").should eq('<mark>oi</mark> <mark>õi</mark> <mark>ôî</mark>') }
      it { subject.highlight_word("áchadoñ o cachorro", "achadon").should eq('<mark>áchadoñ</mark> o cachorro') }
      it { subject.highlight_word("Jürgen", "Jurgen").should eq('<mark>Jürgen</mark>') }

      # TODO: these two could also ignore the accents on 'ṕ' and 'ǹ'
      it { subject.highlight_word("<scríPT> alert() </SCrîṕt>", "script").should eq('&lt;<mark>scríPT</mark>&gt; alert() &lt;/SCrîṕt&gt;') }
      it { subject.highlight_word("admin ÁDmĩǹ", "admin").should eq('<mark>admin</mark> ÁDmĩǹ') }
    end

    context "ignores case" do
      it { subject.highlight_word("oI õi OI", "oi").should eq('<mark>oI</mark> <mark>õi</mark> <mark>OI</mark>') }
      it { subject.highlight_word("Atiramos no Átila", "átila").should eq("Atiramos no <mark>Átila</mark>") }
      it { subject.highlight_word("Atiramos no átila", "Átila").should eq("Atiramos no <mark>átila</mark>") }
    end

    context "ignores entities" do
      it { subject.highlight_word("rafael &nbsp; rafael", "&nbsp;").should eq('rafael <mark>&amp;nbsp;</mark> rafael') }
      it { subject.highlight_word("<scriptero> rafael </scriptero>", "<scr").should eq("<mark>&lt;scr</mark>iptero&gt; rafael &lt;/scriptero&gt;") }
    end

    context "all mixed" do
      it { subject.highlight_word("<mark>admin &nbsp; &gt;", "admin").should eq("&lt;mark&gt;<mark>admin</mark> &amp;nbsp; &amp;gt;") }
      it { subject.highlight_word("<mark>admin &nbsp; &gt;", "&").should eq("&lt;mark&gt;admin <mark>&amp;</mark>nbsp; <mark>&amp;</mark>gt;") }
      it { subject.highlight_word("<mark>admin &nbsp; &gt;", "nbsp;").should eq("&lt;mark&gt;admin &amp;<mark>nbsp;</mark> &amp;gt;") }
      it { subject.highlight_word("<mark>admin &nbsp; &gt;", ";").should eq("&lt;mark&gt;admin &amp;nbsp<mark>;</mark> &amp;gt<mark>;</mark>") }
      it { subject.highlight_word("<mark>admin &nbsp; &gt;", "&gt;").should eq("&lt;mark&gt;admin &amp;nbsp; <mark>&amp;gt;</mark>") }
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
      it { subject.highlight("</script> admin &nbsp; &gt; &amp;", ["&", "<", ">", ";"]).should eq("<mark>&lt;</mark>/script<mark>&gt;</mark> admin <mark>&amp;</mark>nbsp<mark>;</mark> <mark>&amp;</mark>gt<mark>;</mark> <mark>&amp;</mark>amp<mark>;</mark>") }
      it { subject.highlight("Teste de repetição", ["e", "e", "e"]).should eq("T<mark>e</mark>st<mark>e</mark> d<mark>e</mark> r<mark>e</mark>p<mark>e</mark>tição") }
      it { subject.highlight("Teste de repetição", ["e", "est"]).should eq("T<mark>este</mark> d<mark>e</mark> r<mark>e</mark>p<mark>e</mark>tição") }
      it { subject.highlight("Teste de repetição", ["ste", "est"]).should eq("T<mark>este</mark> de repetição") }
      it { subject.highlight("Tesste de letra repetida", ["s"]).should eq("Te<mark>ss</mark>te de letra repetida") }
      it { subject.highlight("Amanda Jackson", ["a", "ja"]).should eq("<mark>A</mark>m<mark>a</mark>nd<mark>a</mark> <mark>Ja</mark>ckson") }
      it { subject.highlight("Amanda (Jackson)", ["("]).should eq("Amanda <mark>(</mark>Jackson)") }
      it { subject.highlight("Amanda (Jackson)", [" "]).should eq("Amanda (Jackson)") }
      end
  end

  context "crop_indexes" do
    it { subject.crop_indexes([]).should eq([]) }
    it { subject.crop_indexes([[0,3]]).should eq([[0,3]]) }
    it { subject.crop_indexes([[0,3],[4,5]]).should eq([[0,3],[4,5]]) }
    it { subject.crop_indexes([[0,3],[0,4]]).should eq([[0,4]]) }
    it { subject.crop_indexes([[0,3],[0,4],[0,6],[0,7]]).should eq([[0,7]]) }
    it { subject.crop_indexes([[0,3],[0,4],[1,6],[5,3]]).should eq([[0,8]]) }
    it { subject.crop_indexes([[0,3],[0,4],[5,6],[5,7]]).should eq([[0,4],[5,7]]) }
    it { subject.crop_indexes([[0,3],[0,4],[4,6],[5,7]]).should eq([[0,12]]) }
    it { subject.crop_indexes([[0,3],[0,4],[5,2],[5,3],[9,1],[9,3]]).should eq([[0,4],[5,3],[9,3]]) }
    it { subject.crop_indexes([[0,3],[4,5],[4,8]]).should eq([[0,3],[4,8]]) }
  end

end
