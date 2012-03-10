class Author < ActiveRecord::Base         
  attr_accessible :_destroy, :name
  
  belongs_to :book
end
