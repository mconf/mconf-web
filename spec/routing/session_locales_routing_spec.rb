# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SessionLocalesController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/language/en").to(action: :create, lang: 'en') }
    it { should route(:get, "/language/pt-br").to(action: :create, lang: 'pt-br') }
    it { should route(:post, "/language/en").to(action: :create, lang: 'en') }
    it { should route(:post, "/language/pt-br").to(action: :create, lang: 'pt-br') }
  end
end
