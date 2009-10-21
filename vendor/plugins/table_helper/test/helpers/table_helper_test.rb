require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TableHelperTest < ActionView::TestCase
  tests TableHelper
  
  class Post
  end
  
  def test_should_build_collection_table
    html = collection_table(['first', 'second', 'last'], Post) do |t|
      t.header :title
      t.rows.each do |row, post_title, index|
        row.title post_title
      end
      t.footer :total, t.collection.length
    end
    
    expected = <<-end_str
      <table cellpadding="0" cellspacing="0" class="posts ui-collection">
        <thead>
          <tr>
            <th class="post-title" scope="col">Title</th>
          </tr>
        </thead>
        <tbody>
          <tr class="post ui-collection-result">
            <td class="post-title">first</td>
          </tr>
          <tr class="post ui-collection-result">
            <td class="post-title">second</td>
          </tr>
          <tr class="post ui-collection-result">
            <td class="post-title">last</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <td class="post-total">3</td>
          </tr>
        </tfoot>
      </table>
    end_str
    assert_html_equal expected, html
  end
end
