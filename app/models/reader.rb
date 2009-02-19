require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'hpricot'


class Reader < ActiveRecord::Base
  
  belongs_to :space
  
  has_many :articles, :dependent => :destroy

  after_create { |reader|
    reader.create_news
  }
  
  def read

    @feed ||= FeedNormalizer::FeedNormalizer.parse open(url)

  end
  
  def create_news
    feed = self.read
    #comparar la fecha guardada del feed con la última fecha de publicación
    if (!self.last_updated || self.last_updated < feed.last_updated) 
      feed.entries.each do |item| 
        unless (self.last_updated && (self.last_updated > item.last_updated))
          a = self.articles.build(
                                  :title => item.title, 
                                  :text => item.content,     
                                  :author => User.find_by_login("Admin"),
                                  :container => Space.find(self.space_id)
                                  )
          a.save
        end
      end
    end
    update_attribute(:last_updated, feed.last_updated)
  end
  
  def find_feed_in_html (html)
    doc = Hpricot(open(html))
    a = doc.get_elements_by_tag_name("link").select { |item|
      (item.attributes["rel"] == "alternate") && ((item.attributes["type"] == "application/rss+xml" ) || (item.attributes["type"] == "application/atom+xml"))
    }
    feed_url = a.first.attributes["href"]
    self.url = (feed_url.include? "http://") ? feed_url : (html + feed_url)    

  end
  
  protected
  
  def validate
    begin
      self.find_feed_in_html (url)
    rescue => a
      self.errors.add_to_base(a.to_s)
      
    end
  end
  
end
