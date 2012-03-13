# coding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

describe Book do
  
  it "should increment tombo before saving" do
    user = create(:user)
    3.times{ create(:book, :user_id => user.id) }
    book = create(:book, :user_id => user.id)
    book.tombo.should == '4'
    
    user = create(:user)
    create(:book, :user_id => user.id)
    book = create(:book, :user_id => user.id)
    book.tombo.should == '2'
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
    isbn = '1606802127'
    faweb_register_book('gbook-proudhon.xml', isbn)
    
    attributes = Book.get_attributes_from_gbook(isbn)
    
    attributes['isbn'].should == isbn
    attributes['title'].should == "What Is Property"
    attributes['subtitle'].should == "An Inquiry Into The Principle Of Right And Of Government"
#   attributes['authors'].should == ["Pierre Joseph Proudhon", "Amédée Jérôme Langlois"]
    attributes['authors'].should == ["Pierre Joseph Proudhon"] 
    attributes['editor'].should == "Forgotten Books"
#    attributes['year'].should == "1969"
    attributes['language'].should == "En"
    attributes['page_number'].should == "457"
  end
  
  it "should belong to an user" do
    user = create(:user)
    book = create(:book, :user_id => user.id)
    
    book.user.should == user
  end
  
  it "should give an error if no user is given" do
    book = build(:book, :user_id => nil)
    book.should_not be_valid
    book.should have(1).error_on(:user_id)
  end

  it "should return the attributes of a book if the book is found in the database" do
    book = create(:book, :isbn => 111)
    author1 = create(:author, :book_id => book.id, :name => "Foo Bar 1")
    author2 = create(:author, :book_id => book.id, :name => "Foo Bar 2")
    
    attributes = Book.get_attributes_from_library(111)
      
    attributes['title'].should == book.title
    attributes['authors'].should == [author1.name, author2.name]
  end
  
  it "should return the attributes of book if found by google book or in the database" do
    isbn = '1606802127'
    faweb_register_book('gbook-proudhon.xml', isbn)
    
    attributes = Book.get_attributes(isbn)
    attributes['isbn'].should == isbn
    attributes['title'].should == "What Is Property"

    book = create(:book, :isbn => isbn, :title => "Title")
    attributes = Book.get_attributes(isbn)
    attributes['isbn'].should == isbn
    attributes['title'].should == book.title 
  end
  
end
