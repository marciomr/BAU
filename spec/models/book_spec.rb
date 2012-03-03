# coding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

describe Book do
  it "should get last tombo" do
    Factory(:book, :tombo => 1)
    Factory(:book, :tombo => 10)
    Factory(:book, :tombo => 6)
    
    Book.last_tombo.should == 10
  end
  
  (Book.columns.select{|b| b.type == :string}.collect{|b| b.name}).each do |field|
    it "should get concatenated #{field}s" do
      Factory(:book, field.to_sym => 'First')
      Factory(:book, field.to_sym => 'Second')
      Factory(:book, field.to_sym => 'Second')
    
      (Book.send "#{field}s").should == ["First", "Second"]
    end
  end
  
  # Example of the above usage
  it "should get concatenated editors" do
    Factory(:book, :editor => 'First')
    Factory(:book, :editor => 'Second')
    Factory(:book, :editor => 'Second')
    
    Book.editors.should == ["First", "Second"]
  end
  
  it "should get concatenated years" do
    Factory(:book, :year => 2000)
    Factory(:book, :year => 2001)
    Factory(:book, :year => 2001)
    
    Book.years.should == [2000, 2001]
  end
  
  Book.complex_fields.each do |k, v|
    it "should get concatenated #{v} of #{k}" do
      values = [Factory(k.singular.to_sym, v.to_sym => 'First'), 
                Factory(k.singular.to_sym, v.to_sym => 'Second')]
      book = Factory(:book, k.to_sym => values)

      (book.send "#{k}_#{v}s").should == "First, Second"
    end
  end

  # Example of the above usage  
  it "should get concatenated names of authors" do
    values = [Factory(:author, :name => 'First'), Factory(:author, :name => 'Second')]
    book = Factory(:book, :authors => values)

    book.authors_names.should == "First, Second"
  end


  it "should get values from google book" do
    params = Book.gbook('1606802127')
    
    params['isbn'].should == '1606802127'
    params['title'].should == "What Is Property"
    params['subtitle'].should == "An Inquiry Into The Principle Of Right And Of Government"
#   params['authors'].should == ["Pierre Joseph Proudhon", "Amédée Jérôme Langlois"]
    params['authors'].should == ["Pierre Joseph Proudhon"] 
    params['editor'].should == "Forgotten Books"
#    params['year'].should == "1969"
    params['language'].should == "En"
    params['page_number'].should == "457"
  end
end
