class SitesController < ApplicationController
    def get_space
     @container = @space = Space.find_by_name("public")
    end
 end