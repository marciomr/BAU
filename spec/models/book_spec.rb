# coding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

describe Book do
  it "should get last tombo" do
    create(:book, :tombo => 1)
    create(:book, :tombo => 10)
    create(:book, :tombo => 6)
    
    Book.last_tombo.should == 10
  end
  
  (Book.columns.select{|b| b.type == :string}.collect{|b| b.name}).each do |field|
    it "should get concatenated #{field}s" do
      create(:book, field.to_sym => 'First')
      create(:book, field.to_sym => 'Second')
      create(:book, field.to_sym => 'Second')
    
      (Book.send "#{field}s").should == ["First", "Second"]
    end
  end
  
  # Example of the above usage
  it "should get concatenated editors" do
    create(:book, :editor => 'First')
    create(:book, :editor => 'Second')
    create(:book, :editor => 'Second')
    
    Book.editors.should == ["First", "Second"]
  end
  
  it "should get concatenated years" do
    create(:book, :year => 2000)
    create(:book, :year => 2001)
    create(:book, :year => 2001)
    
    Book.years.should == [2000, 2001]
  end
  
  Book.complex_fields.each do |k, v|
    it "should get concatenated #{v} of #{k}" do
      values = [create(k.singular.to_sym, v.to_sym => 'First'), 
                create(k.singular.to_sym, v.to_sym => 'Second')]
      book = Factory(:book, k.to_sym => values)

      (book.send "#{k}_#{v}s").should == "First, Second"
    end
  end

  # Example of the above usage  
  it "should get concatenated names of authors" do
    values = [create(:author, :name => 'First'), create(:author, :name => 'Second')]
    book = create(:book, :authors => values)

    book.authors_names.should == "First, Second"
  end

  it "should get values from google book" do
    page = Rails.root.join("spec/fakeweb/gbook-proudhon.xml")
    isbn = '1606802127'
    FakeWeb.register_uri(:get, "http://books.google.com/books/feeds/volumes?q=isbn:#{isbn}", :response => page)
    
    params = Book.gbook(isbn)
    
    params['isbn'].should == isbn
    params['title'].should == "What Is Property"
    params['subtitle'].should == "An Inquiry Into The Principle Of Right And Of Government"
#   params['authors'].should == ["Pierre Joseph Proudhon", "Amédée Jérôme Langlois"]
    params['authors'].should == ["Pierre Joseph Proudhon"] 
    params['editor'].should == "Forgotten Books"
#    params['year'].should == "1969"
    params['language'].should == "En"
    params['page_number'].should == "457"
  end
  
  it "should belong to an user", :focus do
    book = create(:book)
    user = create(:user, :books => [book])
    
    book.user.should == user
  end
  
end
