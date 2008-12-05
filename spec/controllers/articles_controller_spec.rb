require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticlesController do
  include CMS::AuthenticationTestHelper
  fixtures :users ,:spaces , :articles ,:entries , :attachments, :performances, :roles, :permissions
  
  def mock_article(stubs={})
    @mock_article ||= mock_model(Article, stubs)
  end
  def mock_article(stubs={})
    @mock_article ||= mock_model(Entry, stubs)
  end
  def mock_entry(stubs={})
    @mock_entry ||= mock_model(Entry, stubs)
  end  
  
  
    def get_articles
    @fixture_articles = []
    for i in 1..30
      @fixture_articles << articles(:"article_#{i}")
    end
    return @fixture_articles
  end  
  
  
  describe "responding to GET index" do
    
    describe "when you are logged as" do
      
      describe "admin user" do
        before(:each) do
          login_as(:user_admin)
        end
        
        describe "in a private space" do
          
          before(:each) do
            @space = spaces(:espacio)
            get_articles
          end
          
          it "should have correct strings in session" do
            get :index , :space_id => @space.name
            session[:current_tab].should eql("News")
            session[:current_sub_tab].should eql("")
            
          end
          it "should have a title in @title" do
            get :index , :space_id => @space.name
            assigns[:title].should include(@space.name)
            
          end
          it "should expose all space articles as @articles" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            
            get :index , :space_id => @space.name
            assigns[:articles].should == [mock_article]
          end
          
          it "should expose the expand view if params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name , :expanded =>"true"
            response.should render_template('index2')
          end
          
          it "should not expose the expand view if not params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name 
            response.should render_template('index')
          end
          
          it "should paginate the articles using the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name, :per_page => 5
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 5).total_pages
            assigns[:articles].total_pages.should_not == @fixture_articles.paginate(:page => params[:page], :per_page => 3).total_pages
            
          end
          
          it "should paginate 30 :per_page without the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 30).total_pages
            
          end
        end
=begin          describe "with mime type of xml" do
            
            it "should render all articles as xml" do
              request.env["HTTP_ACCEPT"] = "application/xml"
              Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(articles = mock("Array of Articles"))
              articles.should_receive(:to_xml).and_return("generated XML")
              get :index, :space_id => @space.name
              response.body.should == "generated XML"
            end
            
          end
=end          
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            get_articles
          end
          
          it "should have correct strings in session" do
            get :index , :space_id => @space.name
            session[:current_tab].should eql("News")
            session[:current_sub_tab].should eql("")
            
          end
          
          it "should have a title in @title" do
            get :index , :space_id => @space.name
            assigns[:title].should include(@space.name)
            
          end
          it "should expose all public articles as @articles" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
            
            get :index , :space_id => @space.name
            assigns[:articles].should == [mock_article]
          end
          
          it "should expose the expand view if params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name , :expanded =>"true"
            response.should render_template('index2')
          end
          
          it "should not expose the expand view if not params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name 
            response.should render_template('index')
          end
          
          it "should paginate the articles using the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name, :per_page => 5
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 5).total_pages
            assigns[:articles].total_pages.should_not == @fixture_articles.paginate(:page => params[:page], :per_page => 3).total_pages
            
          end
          
          it "should paginate 30 :per_page without the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 30).total_pages
            
          end
        end
      end
      
      
      describe "normal user" do
        
        before(:each) do
          login_as(:user_normal)
        end
        
        describe "in a private space where user has the role User" do
          
          before(:each) do
            @space = spaces(:espacio)
            get_articles
          end
          
          it "should have correct strings in session" do
            get :index , :space_id => @space.name
            session[:current_tab].should eql("News")
            session[:current_sub_tab].should eql("")
          end
          
          it "should have a title in @title" do
            get :index , :space_id => @space.name
            assigns[:title].should include(@space.name)
            
          end
          it "should expose all space articles as @articles" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            
            get :index , :space_id => @space.name
            assigns[:articles].should == [mock_article]
          end
          
          it "should expose the expand view if params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name , :expanded =>"true"
            response.should render_template('index2')
          end
          
          it "should not expose the expand view if not params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name 
            response.should render_template('index')
          end
          
          it "should paginate the articles using the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name, :per_page => 5
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 5).total_pages
            assigns[:articles].total_pages.should_not == @fixture_articles.paginate(:page => params[:page], :per_page => 3).total_pages
            
          end
          
          it "should paginate 30 :per_page without the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 30).total_pages
            
          end
        end
        
        describe "in a private space where user has the role Invited" do
          
          before(:each) do
            @space = spaces(:private_invited)
            get_articles
          end
          
          it "should have correct strings in session" do
            get :index , :space_id => @space.name
            session[:current_tab].should eql("News")
            session[:current_sub_tab].should eql("")
          end
          
          it "should have a title in @title" do
            get :index , :space_id => @space.name
            assigns[:title].should include(@space.name)
            
          end
          it "should expose all space articles as @articles" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            
            get :index , :space_id => @space.name
            assigns[:articles].should == [mock_article]
          end
          
          it "should expose the expand view if params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name , :expanded =>"true"
            response.should render_template('index2')
          end
          
          it "should not expose the expand view if not params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name 
            response.should render_template('index')
          end
          
          it "should paginate the articles using the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name, :per_page => 5
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 5).total_pages
            assigns[:articles].total_pages.should_not == @fixture_articles.paginate(:page => params[:page], :per_page => 3).total_pages
            
          end
          
          it "should paginate 30 :per_page without the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 30).total_pages
            
          end
        end
        
        describe "in a private space where user no has roles" do
          
          before(:each) do
            @space = spaces(:private)
            get_articles
          end
          
          it "should not let user to see the space index with expand" do
            get :index , :space_id => @space.name, :expanded =>"true" 
            assert_response 403
          end
          
          it "should not let user to see the space index with normal view" do
            get :index , :space_id => @space.name 
            assert_response 403
          end
          
          it "should not have @title, sessions, @articles, " do
            get :index , :space_id => @space.name
            assigns[:title].should eql(nil)
            assigns[:articles].should eql(nil)
            session[:current_tab].should eql(nil)
            session[:current_sub_tab].should eql(nil)
          end
          
        end
        
        describe "in the public space" do
          
          before(:each) do
            @space = spaces(:public)
            get_articles
          end
          
          it "should have correct strings in session" do
            get :index , :space_id => @space.name
            session[:current_tab].should eql("News")
            session[:current_sub_tab].should eql("")
          end
          it "should have a title in @title" do
            get :index , :space_id => @space.name
            assigns[:title].should include(@space.name)
          end
          it "should expose all public articles as @articles" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
            
            get :index , :space_id => @space.name
            assigns[:articles].should == [mock_article]
          end
          
          it "should expose the expand view if params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name , :expanded =>"true"
            response.should render_template('index2')
          end
          
          it "should not expose the expand view if not params" do
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
            get :index , :space_id => @space.name 
            response.should render_template('index')
          end
          
          it "should paginate the articles using the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name, :per_page => 5
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 5).total_pages
            assigns[:articles].total_pages.should_not == @fixture_articles.paginate(:page => params[:page], :per_page => 3).total_pages
            
          end
          
          it "should paginate 30 :per_page without the param :per_page" do
            
            Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_articles)
            get :index , :space_id => @space.name
            assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 30).total_pages
            
          end
        end
      end
    end
    
    describe "If you are not logged in" do
      
      describe "in a private space" do
        
        before(:each) do
          @space = spaces(:espacio)
          get_articles
        end
        
        it "should not let user to see the space index with expand view" do
          get :index , :space_id => @space.name, :expanded =>"true" 
          assert_response 403
        end
        
        it "should not let user to see the space index with normal view" do
          get :index , :space_id => @space.name 
          assert_response 403
        end
        
        it "should not have @title, sessions, @articles, " do
          get :index , :space_id => @space.name
          assigns[:title].should eql(nil)
          assigns[:articles].should eql(nil)
          session[:current_tab].should eql(nil)
          session[:current_sub_tab].should eql(nil)
        end
        
      end
      
      describe "in the public space" do
        
        before(:each) do
          @space = spaces(:public)
          get_articles
        end
        
        it "should have correct strings in session" do
          get :index , :space_id => @space.name
          session[:current_tab].should eql("News")
          session[:current_sub_tab].should eql("")
        end
        
        it "should have a title in @title" do
          get :index , :space_id => @space.name
          assigns[:title].should include(@space.name)
          
        end
        it "should expose all public articles as @articles" do
          Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
          
          get :index , :space_id => @space.name
          assigns[:articles].should == [mock_article]
        end
        
        it "should expose the expand view if params" do
          Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
          get :index , :space_id => @space.name , :expanded =>"true"
          response.should render_template('index2')
        end
        
        it "should not expose the expand view if not params" do
          Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return([mock_article])
          get :index , :space_id => @space.name 
          response.should render_template('index')
        end
        
        it "should paginate the articles using the param :per_page" do
          
          Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_articles)
          get :index , :space_id => @space.name, :per_page => 5
          assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 5).total_pages
          assigns[:articles].total_pages.should_not == @fixture_articles.paginate(:page => params[:page], :per_page => 3).total_pages
          
        end
        
        it "should paginate 30 :per_page without the param :per_page" do
          
          Article.should_receive(:find).with(:all,{:order=>"updated_at DESC", :conditions=>{"entries.public_read"=>true, "entries.parent_id"=>nil}}).and_return(@fixture_articles)
          get :index , :space_id => @space.name
          assigns[:articles].total_pages.should == @fixture_articles.paginate(:page => params[:page], :per_page => 30).total_pages
          
        end
      end  
      
    end
  end 
  
  
  
  ###################################
  
  describe "responding to GET show" do
    # Para realizar estos tests, después de intentar realizarlos a base de emplear mocks, se ha comprobado que resulta muy complicado
    # simular el comportamiento. Por ello se ha optado por usar fixtures. Para ello se han creado 4 objetos entries. Uno de ellos es el
    # entry padre que tiene asociado un artículo (parent_article). Además hay 2 entries que tienen asociado 2 artículos y un entry que 
    # tiene asociado un attachment. Estos 3 últimos entries tendrán un parent_id apuntando al entry padre para indicar que están relacionados  
    #           
    describe "when you are logged as" do
      describe "superadmin" do
        before(:each)do
        login_as(:user_admin)
      end
      
      describe "in a private space" do
        
        before(:each) do
          @space = spaces(:espacio)
          @parent_article = articles(:parent_article)
          @children1_article = articles(:children_article1)
          # @mock_entry_parent = mock_model(Entry, :children => [])
          # @mock_article =  mock_model(Article,{:title => "mock_article_title", :entry => @mock_entry_parent})
          
        end
        
        it "should expose the requested article as @article" do
          Article.stub!(:find).and_return(@parent_article)
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:article].should == (@parent_article)
          
        end
        
        it " should have the article title in @title" do
          Article.stub!(:find).and_return(@parent_article)
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:title].should == @parent_article.title
        end
        
        it "should return the entries with attachment in @attachment_children" do
          Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
        end
        
        it "should return the article children in @comment_children" do
          Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 4 childrens
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:comment_children].size == 2
          assigns[:comment_children].should include(entries(:entry_children1),entries(:entry_children2))
          
        end
        
        it "should return [] if no attachments children" do
          Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == []
        end
        
        it "should return [] if no articles children" do
          Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:comment_children].should == []
        end
      end
      
      #         describe "with mime type of xml" do
      
      #           it "should render the requested article as xml" do
      #             request.env["HTTP_ACCEPT"] = "application/xml"
      #             Article.should_receive(:find).with("37").and_return(mock_article)
      #             mock_article.should_receive(:to_xml).and_return("generated XML")
      #             get :show, :id => "37"
      #             response.body.should == "generated XML"
      #           end
      
      #         end
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
          @parent_article = articles(:parent_article)
          @children1_article = articles(:children_article1)
          #  @mock_entry_parent = mock_model(Entry, :children => [])
          #  @mock_article =  mock_model(Article,{:title => "mock_article_title", :entry => @mock_entry_parent})
          
        end
        
        it "should expose the requested article as @article" do
          Article.stub!(:find).and_return(@parent_article)
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:article].should == (@parent_article)
          
        end
        
        it " should have the article title in @title" do
          Article.stub!(:find).and_return(@parent_article)
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:title].should == @parent_article.title
        end
        
        it "should return the entries with attachment in @attachment_children" do
          Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
        end
        
        it "should return the article children in @comment_children" do
          Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 4 childrens
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:comment_children].size == 2
          assigns[:comment_children].should include(entries(:entry_children1),entries(:entry_children2))
          
        end
        
        it "should return [] if no attachments children" do
          Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == []
        end
        
        it "should return [] if no articles children" do
          Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
          
          get :show, :id => "37" , :space_id => @space.name
          assigns[:comment_children].should == []
        end
      end
    end  
    
    describe "normal user"do
    before(:each)do
    login_as(:user_normal)
  end
  describe "in a private space where the user has the role User" do
    before(:each) do
      @space = spaces(:espacio)
      @parent_article = articles(:parent_article)
      @children1_article = articles(:children_article1)
      #@mock_entry_parent = mock_model(Entry, :children => [])
      #@mock_article =  mock_model(Article,{:title => "mock_article_title", :entry => @mock_entry_parent})
      
    end
    
    it "should expose the requested article as @article" do
      Article.stub!(:find).and_return(@parent_article)
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:article].should == (@parent_article)
      
    end
    
    it " should have the article title in @title" do
      Article.stub!(:find).and_return(@parent_article)
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:title].should == @parent_article.title
    end
    
    it "should return the entries with attachment in @attachment_children" do
      Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
    end
    
    it "should return the article children in @comment_children" do
      Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 4 childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:comment_children].size == 2
      assigns[:comment_children].should include(entries(:entry_children1),entries(:entry_children2))
      
    end
    
    it "should return [] if no attachments children" do
      Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:attachment_children].should == []
    end
    
    it "should return [] if no articles children" do
      Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:comment_children].should == []
    end
  end
  
  describe "in a private space where the user has the role Invited" do
    before(:each) do
      @space = spaces(:private_invited)
      @parent_article = articles(:parent_article)
      @children1_article = articles(:children_article1)
      
    end
    
    it "should expose the requested article as @article" do
      Article.stub!(:find).and_return(@parent_article)
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:article].should == (@parent_article)
      
    end
    
    it " should have the article title in @title" do
      Article.stub!(:find).and_return(@parent_article)
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:title].should == @parent_article.title
    end
    
    it "should return the entries with attachment in @attachment_children" do
      Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
    end
    
    it "should return the article children in @comment_children" do
      Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 4 childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:comment_children].size == 2
      assigns[:comment_children].should include(entries(:entry_children1),entries(:entry_children2))
      
    end
    
    it "should return [] if no attachments children" do
      Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:attachment_children].should == []
    end
    
    it "should return [] if no articles children" do
      Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:comment_children].should == []
    end
  end
  
  describe "in a private space where user have not roles on it" do
    before(:each) do
      @space = spaces(:private)
      @parent_article = articles(:parent_article)
      @children1_article = articles(:children_article1)
    end         
    
    #en estos  casos debería saltar el filtro directamente en vez de andar haciendo búsquedas que dicen que no hay usuario
    it "should not let the user to see the article with an inexistent article" do 
      assert_raise ActiveRecord::RecordNotFound do
         get :show, :id => "254" , :space_id => @space.name
       end
    end

    it "should not let the user to see an article belonging to this space" do   
        get :show, :id => articles(:private_article).id , :space_id => @space.name
        assert_response 403
    end
  end
  
  describe "in the public space" do
    
    before(:each) do
      @space = spaces(:public)
      @parent_article = articles(:parent_article)
      @children1_article = articles(:children_article1)
      
    end
    
    it "should expose the requested article as @article" do
      Article.stub!(:find).and_return(@parent_article)
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:article].should == (@parent_article)
      
    end
    
    it " should have the article title in @title" do
      Article.stub!(:find).and_return(@parent_article)
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:title].should == @parent_article.title
    end
    
    it "should return the entries with attachment in @attachment_children" do
      Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
    end
    
    it "should return the article children in @comment_children" do
      Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 4 childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:comment_children].size == 2
      assigns[:comment_children].should include(entries(:entry_children1),entries(:entry_children2))
      
    end
    
    it "should return [] if no attachments children" do
      Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:attachment_children].should == []
    end
    
    it "should return [] if no articles children" do
      Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
      
      get :show, :id => "37" , :space_id => @space.name
      assigns[:comment_children].should == []
    end
  end
end
end 
describe "if you are not logged in " do

describe "a private space" do
  before(:each) do
    @space = spaces(:private)      
  end
   #en estos  casos debería saltar el filtro directamente en vez de andar haciendo búsquedas que dicen que no hay usuario
    it "should not let the user to see the article with an inexistent article" do 
      assert_raise ActiveRecord::RecordNotFound do
         get :show, :id => "254" , :space_id => @space.name
       end
    end

    it "should not let the user to see an article belonging to this space" do   
        get :show, :id => articles(:private_article).id , :space_id => @space.name
        assert_response 403
    end
  end
describe "in the public space" do  
  before(:each) do
    @space = spaces(:public)
    @public_article = articles(:public_article)
    @public_children_article1 = articles(:public_children_article1)
    get_articles

    
  end
  
  it "should expose the requested article as @article" do
    Article.stub!(:find).and_return(@public_article)
    get :show, :id => "37" , :space_id => @space.name
    assigns[:article].should == (@public_article)
  end
  
  it " should have the article title in @title" do
    Article.stub!(:find).and_return(@public_article)
    get :show, :id =>"37" , :space_id => @space.name
      assigns[:title].should == @public_article.title
  end
  
  it "should return the entries with attachment in @attachment_children" do
    Article.stub!(:find).and_return(@public_article) # give the parent article, which have 3 childrens
    
    get :show, :id => "37" , :space_id => @space.name
    assigns[:attachment_children].should == [entries(:entry_public_attachment_children3)]
end

it "should return the article children in @comment_children" do
  Article.stub!(:find).and_return(@public_article) # give the parent article, which have 4 childrens
  
  get :show, :id => "37" , :space_id => @space.name
    assigns[:comment_children].size == 2
    assigns[:comment_children].should include(entries(:entry_public_children1),entries(:entry_public_children2))
end

it "should return [] if no attachments children" do
  Article.stub!(:find).and_return(@public_children_article1) #give a children_article , which have not any childrens
  
  get :show, :id => "37" , :space_id => @space.name
    assigns[:attachment_children].should == []
end

it "should return [] if no articles children" do
  Article.stub!(:find).and_return(@public_children_article1) #give a children_article , which have not any childrens
  
  get :show, :id => "37" , :space_id => @space.name
  assigns[:comment_children].should == []
end
end
end
end



##########################################
describe "responding to GET new" do
  
  describe "when you are logged as " do
    
    describe "super admin" do
      
      before(:each) do
        login_as(:user_admin)
      end
      describe "in a private space" do
        before(:each) do
          @space = spaces(:espacio)
          @new_article =  Article.new
          @new_entry = Entry.new
        end
        
        it "should have correct strings in session" do
          get :new , :space_id => @space.name
          session[:current_sub_tab].should eql("New article")
        end
        
        it "should expose a new article as @article" do
          Article.should_receive(:new).and_return(@new_article)
          get :new , :space_id => @space.name
          assigns[:article].should equal(@new_article)
        end
        
        it "should have a title in @title" do
          
          Article.should_receive(:new).and_return(@new_article)
          get :new , :space_id => @space.name
          assigns[:title].should_not eql(nil)
          assigns[:title].should include("New Article")
        end
        
        it "should have an associated entry " do
          Article.should_receive(:new).and_return(@new_article)
          @new_article.stub!(:entry).and_return(@new_entry)
          get :new , :space_id => @space.name
          assigns[:article].entry.should_not eql(nil)
          assigns[:article].entry.should eql(@new_entry)
        end
      end
      
      
      describe "in a pubic space" do
        before(:each) do
          @space = spaces(:public)
          @new_article =  Article.new
          @new_entry = Entry.new
        end
        
        it "should have correct strings in session" do
          get :new , :space_id => @space.name
          session[:current_sub_tab].should eql("New article")
        end
        
        it "should expose a new article as @article" do
          Article.should_receive(:new).and_return(@new_article)
          get :new , :space_id => @space.name
          assigns[:article].should equal(@new_article)
        end
        
        it "should have a title in @title" do
          
          Article.should_receive(:new).and_return(@new_article)
          get :new , :space_id => @space.name
          assigns[:title].should_not == nil
          assigns[:title].should include("New Article")
        end
        
        it "should have an associated entry " do
          Article.should_receive(:new).and_return(@new_article)
          @new_article.stub!(:entry).and_return(@new_entry)
          get :new , :space_id => @space.name
          assigns[:article].entry.should_not eql(nil)
          assigns[:article].entry.should eql(@new_entry)
        end
        
      end
      
    end
    
    describe "normal User" do
      
      before(:each) do
        login_as(:user_normal)
      end
      describe "in a private space" do
        
        describe "where the user belongs to it" do
          before(:each) do
            @space = spaces(:espacio)
            @new_article =  Article.new
            @new_entry = Entry.new
          end
          
          it "should have correct strings in session" do
            get :new , :space_id => @space.name
            session[:current_sub_tab].should eql("New article")
          end
          
          it "should expose a new article as @article" do
            Article.should_receive(:new).and_return(@new_article)
            get :new , :space_id => @space.name
            assigns[:article].should equal(@new_article)
          end
          
          it "should have a title in @title" do
            
            Article.should_receive(:new).and_return(@new_article)
            get :new , :space_id => @space.name
            assigns[:title].should_not eql(nil)
            assigns[:title].should include("New Article")
          end
          
          it "should have an associated entry " do
            Article.should_receive(:new).and_return(@new_article)
            @new_article.stub!(:entry).and_return(@new_entry)
            get :new , :space_id => @space.name
            assigns[:article].entry.should_not eql(nil)
            assigns[:article].entry.should eql(@new_entry)
          end
        end
        
        describe "where ther user not belongs to it" do
          before(:each) do
            @space = spaces(:private)
            @new_article =  Article.new
          end
          
          it "should not let the user do the action" do
            get :new , :space_id => @space.name
            assert_response 403
          end
          it "should not have @article, @entry, @title, session[:current_sub_tab]" do
            get :new , :space_id => @space.name
            assigns[:title].should eql(nil)
            session[:current_sub_tab].should eql(nil)
            assigns[:article].should eql(nil)
            session[:entry].should eql(nil)
          end
          
        end
        
      end
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
          @new_article =  Article.new
          @new_entry = Entry.new
        end
        
        it "should have correct strings in session []" do
          get :new , :space_id => @space.name
          pending("no debería hacer un render 403") do
            session[:current_sub_tab].should eql("New article")
          end
        end
        
        it "should expose a new article as @article" do
          Article.should_receive(:new).and_return(@new_article)
          get :new , :space_id => @space.name
          pending("no debería hacer un render 403") do
            assigns[:article].should equal(@new_article)
          end
        end
        
        it "should have a title in @title" do
          
          Article.should_receive(:new).and_return(@new_article)
          get :new , :space_id => @space.name
          pending("no debería hacer un render 403") do
            assigns[:title].should_not eql(nil)
            assigns[:title].should include("New Article")
          end
        end
        
        it "should have an associated entry " do
          pending("no debería hacer un render 403") do
            Article.should_receive(:new).and_return(@new_article)
            @new_article.stub!(:entry).and_return(@new_entry)
            get :new , :space_id => @space.name
            assigns[:article].entry.should_not eql(nil) #falla en el @article.entry que no debería ser nil el @article
            assigns[:article].entry.should eql(@new_entry)
          end
        end
        
      end
    end
  end
  describe "if you are not logged in" do
    
    describe "a private space" do
      before(:each) do
        @space = spaces(:espacio)
      end
      it "should not let the user do the action" do
        get :new , :space_id => @space.name
        assert_response 403
      end
      it "should not have @article, @entry, @title, session[:current_sub_tab]" do
        get :new , :space_id => @space.name
        assigns[:title].should eql(nil)
        session[:current_sub_tab].should eql(nil)
        assigns[:article].should eql(nil)
        session[:entry].should eql(nil)
      end
    end
    describe "the public space" do
      before(:each) do
        @space = spaces(:public)
      end
      it "should not let the user do the action" do
        get :new , :space_id => @space.name
        assert_response 403
      end
      it "should not have @article, @entry, @title, session[:current_sub_tab]" do
        get :new , :space_id => @space.name
        assigns[:title].should eql(nil)
        session[:current_sub_tab].should eql(nil)
        assigns[:article].should eql(nil)
        session[:entry].should eql(nil)
      end
    end
  end
end

#####################################
describe "responding to GET edit" do
  
  describe "when you are login as" do
    
    describe "superadmin" do
      ### the superadmin can edit all articles of the aplication
      before(:each)do
      login_as(:user_admin)
    end
    
      describe "in a private space" do
        before(:each)do
        @space = spaces(:espacio)
        @parent_article = articles(:parent_article)
        @children1_article = articles(:children_article1)
        end
    
        it "should expose the requested article as @article" do
          Article.stub!(:find).and_return(@parent_article)
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:article].should equal(@parent_article)
        end
    
        it "should have an associated entry " do
          Article.stub!(:find).and_return(@parent_article)
          get :edit ,:id=> "37", :space_id => @space.name
          assigns[:article].entry.should_not eql(nil)
          assigns[:article].entry.should eql(@parent_article.entry)
        end
    
        it "should return the entries with attachment in @attachment_children" do
          Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
        end
    
        it "should return [] if no attachments children" do
          Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == []
        end
     end
     describe "in the public space" do
       before(:each)do
         @space = spaces(:public)
         @parent_article = articles(:parent_article)
         @children1_article = articles(:children_article1)
       end
       
       it "should expose the requested article as @article" do
          Article.stub!(:find).and_return(@parent_article)
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:article].should equal(@parent_article)
        end
    
        it "should have an associated entry " do
          Article.stub!(:find).and_return(@parent_article)
          get :edit ,:id=> "37", :space_id => @space.name
          assigns[:article].entry.should_not eql(nil)
          assigns[:article].entry.should eql(@parent_article.entry)
        end
    
        it "should return the entries with attachment in @attachment_children" do
          Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
        end
    
        it "should return [] if no attachments children" do
          Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == []
        end
     end
  end
  
  describe "normal user" do
    
    before(:each)do
      login_as(:user_normal)
    end
  
    describe "in a private space" do
      describe "where the user belongs to it" do
        
        before(:each)do
          @space = spaces(:espacio)
          @parent_article = articles(:parent_article)
          @children1_article = articles(:children_article1)
        end
         
         it "should expose the requested article as @article" do
          Article.stub!(:find).and_return(@parent_article)
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:article].should equal(@parent_article)
        end
    
        it "should have an associated entry " do
          Article.stub!(:find).and_return(@parent_article)
          get :edit ,:id=> "37", :space_id => @space.name
          assigns[:article].entry.should_not eql(nil)
          assigns[:article].entry.should eql(@parent_article.entry)
        end
    
        it "should return the entries with attachment in @attachment_children" do
          Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
        end
    
        it "should return [] if no attachments children" do
          Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == []
        end
    end
    
    describe"where the user not belongs to it" do
      
      before(:each)do
        @space = spaces(:private)
      end
      
         it "should not let user to edit an article" do
            get :edit , :id =>"37", :space_id => @space.name 
            assert_response 403
          end
      end
   end
   describe "in the public space" do
     
     before(:each)do
       @space = spaces(:public)
       @parent_article = articles(:parent_article)
       @children1_article = articles(:children_article1)
     end
        it "should expose the requested article as @article" do
          Article.stub!(:find).and_return(@parent_article)
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:article].should equal(@parent_article)
        end
    
        it "should have an associated entry " do
          Article.stub!(:find).and_return(@parent_article)
          get :edit ,:id=> "37", :space_id => @space.name
          assigns[:article].entry.should_not eql(nil)
          assigns[:article].entry.should eql(@parent_article.entry)
        end
    
        it "should return the entries with attachment in @attachment_children" do
          Article.stub!(:find).and_return(@parent_article) # give the parent article, which have 3 childrens
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == [entries(:entry_attachment_children3)]
        end
    
        it "should return [] if no attachments children" do
          Article.stub!(:find).and_return(@children1_article) #give a children_article , which have not any childrens
          get :edit, :id => "37" , :space_id => @space.name
          assigns[:attachment_children].should == []
        end
     end
  end
end



  describe "if you are not logged in" do
    describe "a private space" do
      before(:each)do
        @space = spaces(:espacio)
    end
    
      it "should not let user to edit an inexistent article" do
           assert_raise ActiveRecord::RecordNotFound do
            get :edit , :id =>"37777", :space_id => @space.name  
            end
        end
       it "should not let user to edit an existent article" do

            get :edit , :id =>"25", :space_id => @space.name 
            assert_response 403 #(no debería dar un no autorización???)

          end
     end
     describe "the public space" do
      before(:each)do
        @space = spaces(:public)
        @parent_article = articles(:parent_article)
       @children1_article = articles(:children_article1)
     end
        it "should not let user to edit an inexistent article" do
             ##este es el comportamiento normal de rails
            assert_raise ActiveRecord::RecordNotFound do
            get :edit , :id =>"37777", :space_id => @space.name  
            end
        end
        
         it "should not let user to edit an existent article" do
            get :edit , :id =>"25", :space_id => @space.name 

        end  
     end
  end
end



#####################################################
describe "responding to POST create" do

describe "with valid params" do

it "should expose a newly created article as @article" do
Article.should_receive(:new).with({'these' => 'params'}).and_return(mock_article(:save => true))
post :create, :article => {:these => 'params'}
assigns(:article).should equal(mock_article)
end

it "should redirect to the created article" do
Article.stub!(:new).and_return(mock_article(:save => true))
post :create, :article => {}
response.should redirect_to(article_url(mock_article))
end

end

describe "with invalid params" do

it "should expose a newly created but unsaved article as @article" do
Article.stub!(:new).with({'these' => 'params'}).and_return(mock_article(:save => false))
post :create, :article => {:these => 'params'}
assigns(:article).should equal(mock_article)
end

it "should re-render the 'new' template" do
Article.stub!(:new).and_return(mock_article(:save => false))
post :create, :article => {}
response.should render_template('new')
end

end

end

describe "responding to PUT udpate" do

describe "with valid params" do

it "should update the requested article" do
Article.should_receive(:find).with("37").and_return(mock_article)
mock_article.should_receive(:update_attributes).with({'these' => 'params'})
put :update, :id => "37", :article => {:these => 'params'}
end

it "should expose the requested article as @article" do
Article.stub!(:find).and_return(mock_article(:update_attributes => true))
put :update, :id => "1"
assigns(:article).should equal(mock_article)
end

it "should redirect to the article" do
Article.stub!(:find).and_return(mock_article(:update_attributes => true))
put :update, :id => "1"
response.should redirect_to(article_url(mock_article))
end

end

describe "with invalid params" do

it "should update the requested article" do
Article.should_receive(:find).with("37").and_return(mock_article)
mock_article.should_receive(:update_attributes).with({'these' => 'params'})
put :update, :id => "37", :article => {:these => 'params'}
end

it "should expose the article as @article" do
Article.stub!(:find).and_return(mock_article(:update_attributes => false))
put :update, :id => "1"
assigns(:article).should equal(mock_article)
end

it "should re-render the 'edit' template" do
Article.stub!(:find).and_return(mock_article(:update_attributes => false))
put :update, :id => "1"
response.should render_template('edit')
end



end

describe "responding to DELETE destroy" do

it "should destroy the requested article" do
Article.should_receive(:find).with("37").and_return(mock_article)
mock_article.should_receive(:destroy)
delete :destroy, :id => "37"
end

it "should redirect to the articles list" do
Article.stub!(:find).and_return(mock_article(:destroy => true))
delete :destroy, :id => "1"
response.should redirect_to(articles_url)
end

end 
end
end
