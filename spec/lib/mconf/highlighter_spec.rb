# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2016 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::Highlighter do
  subject {Mconf::Highlighter}

  context "#highlight_word" do

    it {subject.highlight_word("", "achei!").should_not eq nil}

    it {subject.highlight_word("", "").should eq ('')}

    it {subject.highlight_word("oi", "oi").should eq('<mark>oi</mark>')}

    it {subject.highlight_word("oì", "ói").should eq('<mark>oì</mark>')}

    it {subject.highlight_word("oi oi", "oi").should eq('<mark>oi</mark> <mark>oi</mark>')}

    it {subject.highlight_word("oi oi oi", "oi").should eq('<mark>oi</mark> <mark>oi</mark> <mark>oi</mark>')}

    it {subject.highlight_word("", "achei!").should eq ('')}

    it {subject.highlight_word("achei!", "").should eq ("achei!")} #bizarroooooo

    it {subject.highlight_word("áchadoñ o cachorro", "áchadoñ").should eq ('<mark>áchadoñ</mark> o cachorro')} 

    it{subject.highlight_word("áchadoñ o cachorro", "achadon").should eq ('<mark>áchadoñ</mark> o cachorro')}

    it{subject.highlight_word("como se fala sópa?", "como").should eq ("<mark>como</mark> se fala sópa?")}

    it{subject.highlight_word("atirei no pescador", "atirei ").should eq ("<mark>atirei </mark>no pescador")}

    it{subject.highlight_word("Atiramos no Átila", "Átila").should eq ("Atiramos no <mark>Átila</mark>")}

    it{subject.highlight_word("Atiramos no Átila", "átila").should eq ("Atiramos no <mark>Átila</mark>")}

    it{subject.highlight_word("Atiramos no átila", "Átila").should eq ("Atiramos no <mark>átila</mark>")}
  end

  context "#highlight" do
    it{subject.highlight("atirei no pescador",["atirei","pescador"]).should eq ("<mark>atirei</mark> no <mark>pescador</mark>")}

    it{subject.highlight("Mark waldberg é um idiota", ["idiota","mark"]).should eq ("<mark>Mark</mark> waldberg é um <mark>idiota</mark>")}

    it{subject.highlight("Mark mata cachorrinhos inocentes", ["cachorrinhos","cachorros"]).should eq ("Mark mata <mark>cachorrinhos</mark> inocentes")}

    it {subject.highlight("oi oi oi", "oi").should eq('<mark>oi</mark> <mark>oi</mark> <mark>oi</mark>')}
  end


end


# TO DO
#ñ e diferentões
#vazio
# 1 das 2 vazias
#todos os testes com e sem acento (e o oposto)
# diferentes tipos de acento e encodings
