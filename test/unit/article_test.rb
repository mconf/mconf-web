require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  
  def test_should_parse_atom
    data = prepare_atom("title", "contenido", nil, "public", {:tag1 => "t1", :tag2 => "t2"})
    params = Article.atom_parser(data)
    assert params.include?(:entry)
    assert params.include?(:article)
    assert params.include?(:tags)
    assert_equal "title", params[:article][:title]
    assert_equal "contenido", params[:article][:text]
    assert_equal nil, params[:entry][:parent_id]
    assert_equal true, params[:entry][:public_read]
    assert_equal "t1,t2", params[:tags]
  end
  
  def test_should_parse_atom2
    data = prepare_atom("title", "contenido", nil, "private", {:tag1 => "t1", :tag2 => "t2"})
    params = Article.atom_parser(data)
    assert params.include?(:entry)
    assert params.include?(:article)
    assert params.include?(:tags)
    assert_equal "title", params[:article][:title]
    assert_equal "contenido", params[:article][:text]
    assert_equal nil, params[:entry][:parent_id]
    assert_equal false, params[:entry][:public_read]
    assert_equal "t1,t2", params[:tags]
  end
  
  
  protected
  
    def prepare_atom(title, content, parent_id, visibility, options = {})
    d = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <entry xmlns:sir=\"http://sir.dit.upm.es/schema\" 
    xmlns:gd=\"http://schemas.google.com/g/2005\" 
    xmlns:thr=\"http://purl.org/syndication/thread/1.0\"
    xml:lang=\"en-US\" xmlns=\"http://www.w3.org/2005/Atom\">  
    <id>tag:localhost,2005:Article/11</id>  
    <published>2008-10-02T12:33:50+02:00</published>  
    <updated>2008-10-02T12:33:50+02:00</updated>  
    <link type=\"text/html\" rel=\"alternate\" href=\"/spaces/2/articles/11\"/>  
    <link type=\"application/atom+xml\" rel=\"self\" href=\"/spaces/2/articles/11.atom\"/>  
    <title>#{ title }</title>  
    <content type=\"html\">#{ content }</content>  
    <thr:in-reply-to>#{ parent_id }</thr:in-reply-to>  
    <gd:visibility>#{ visibility }</gd:visibility>
    <category term=\"#{ options[:tag1] }\"/>
    <category term=\"#{ options[:tag2] }\"/>  
    </entry>"
  end
  
end
