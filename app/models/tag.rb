class Tag < ActiveRecord::Base
  attr_accessible :_destroy, :title
  
  belongs_to :book
end
