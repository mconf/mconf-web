# A migration to set needed tables for CMS support
ActiveRecord::Base.record_timestamps = false

class MigrationPost < ActiveRecord::Base
  set_table_name 'cms_posts'

  def self.change(from, to)
    self.find(:all, :conditions => [ "content_type = ?", from ]).each do |p|
      p.update_attribute :content_type, to
    end
  end

  def self.up
    change "CMS::AttachmentFu", "Attachment"
    change "CMS::Text", "XhtmlText"
  end


  def self.down
    change "Attachment", "CMS::AttachmentFu"
    change "XhtmlText", "CMS::Text"
  end
end

class Cmsplugin2 < ActiveRecord::Migration
  def self.up
    create_table :anonymous_agents do |t|
    end

    rename_table :cms_attachment_fus, :attachments
    rename_table :cms_texts, :xhtml_texts
    MigrationPost.up

    rename_table :cms_categories, :categories
    rename_table :cms_categorizations, :categorizations
    rename_table :cms_performances, :performances
    rename_table :cms_posts, :posts
    rename_table :cms_roles, :roles
    remove_index :cms_uris, :uri
    rename_table :cms_uris, :uris
    add_index :uris, :uri
  end

  def self.down
    drop_table :anonymous_agents
    rename_table :attachments, :cms_attachment_fus
    rename_table :xhtml_texts, :cms_texts
    rename_table :categories, :cms_categories
    rename_table :categorizations, :cms_categorizations
    rename_table :performances, :cms_performances
    rename_table :posts, :cms_posts
    MigrationPost.down

    rename_table :roles, :cms_roles
    remove_index :uris, :uri
    rename_table :uris, :cms_uris
    add_index :cms_uris, :uri
  end
end
