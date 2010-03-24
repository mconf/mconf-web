require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hfeed'

context "A parsed hEntry object" do
  setup do
    $hentry ||= HEntry.find(:first => fixture(:hatom), :base => 'http://errtheblog.com')
  end

  specify "should have a title" do
    $hentry.entry_title.should.equal "&ldquo;A Rails Toolbox&rdquo;"
  end

  specify "should have an author string " do
    $hentry.author.should.be.an.instance_of HCard
    $hentry.author.fn.should.equal "Chris"
  end

  specify "should have an author when there are no entry author but a nearest in parent hcard" do
    with_parent = HEntry.find(:first => fixture(:redflavor),
                             :base => 'http://journal.redflavor.com')
    with_parent.author.should.be.an.instance_of HCard
    with_parent.author.fn.should.equal "Eivind Uggedal"
    with_parent.author.url.should.equal "http://redflavor.com"
  end

  specify "should be invalid without any author in strict mode" do
    proc { HEntry.find(:first => fixture(:hatom_without_author),
                       :base => 'http://bogus.redflavor.com',
                       :strict => true) }.should.raise InvalidMicroformat
  end

  specify "should have content" do
    $hentry.entry_content.should.be.an.instance_of String
  end

  specify "should have an attached published date object" do
    $hentry.published.should.be.an.instance_of Time
  end

  specify "should have an inferred updated attribute which references the published date object" do
    $hentry.updated.should.be.an.instance_of Time
    $hentry.updated.should.be $hentry.published
  end

  specify "should have a bookmark (permalink)" do
    $hentry.bookmark.should.equal "/post/13"
  end

  specify "should have an array of tags" do
    $hentry.tags.should.be.an.instance_of Array
  end

  specify "should know its Atom representation" do
    to_atom = $hentry.to_atom
    expected = <<-end_atom
      <entry>
        <id>tag:errtheblog.com,2008
        <link type="text/html" href="http://errtheblog.com/post/13" rel="alternate"/>
        <title>&ldquo;A Rails Toolbox&rdquo;</title>
        <content type="html">
          &lt;img 
          src=
          http://errtheblog.com/static/images/pink-toolbox.jpg
          &lt;p&gt;
        </content>
        <author>
          <name>Chris</name>
        </author>
      </entry>
    end_atom

    expected.split("\n").each do |line|
      to_atom.should.include line.strip
    end
  end
end

context "An hFeed" do
  setup do
    $hentries ||= HEntry.find(:all => fixture(:hatom), :base => 'http://errtheblog.com/posts/rss')
  end

  specify "should know its atom id" do
    $hentries.first.atom_id.should == "<id>tag:errtheblog.com,2008-01-22:a7ec6beee025594bbed6817b361e0e45</id>"

  end

  specify "should know its Atom representation" do
    to_atom = $hentries.to_atom(:title => 'Err the Blog')
    expected = <<-end_atom
      <entry>
        <id>http://errtheblog.com/posts/rss</id>
        <link type="text/html" href="http://errtheblog.com/post/13" rel="alternate"/>
        <title>Err the Blog</title>
        <content type="html">
          &lt;img 
          src=
          http://errtheblog.com/static/images/pink-toolbox.jpg
          &lt;p&gt;
        </content>
        <updated>
        <author>
          <name>Chris</name>
        </author>
      </entry>
    end_atom

    expected << <<-end_atom
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">
      <link type="text/html" href="
    </feed>
    end_atom

    expected.split("\n").each do |line|
      to_atom.should.include line.strip
    end
  end
end
