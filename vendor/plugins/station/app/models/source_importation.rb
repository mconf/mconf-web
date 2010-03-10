class SourceImportation < ActiveRecord::Base
  belongs_to :source
  belongs_to :importation, :polymorphic => true, :dependent => :destroy
  belongs_to :uri
end
