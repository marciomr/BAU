class Tag < ActiveRecord::Base
  belongs_to :books
  
  attr_accessible :title, :should_destroy
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
end
