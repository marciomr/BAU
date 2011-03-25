require File.dirname(__FILE__) + '/../spec_helper'

describe Book do
  it "should get last tombo" do
    Factory(:book, :tombo => 1)
    Factory(:book, :tombo => 10)
    Factory(:book, :tombo => 6)
    
    Book.last_tombo.should == 10
  end
end
