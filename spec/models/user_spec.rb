# coding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  
  it "should get last tombo" do
    user = create(:user)
    create(:book, :user_id => user.id)
    create(:book, :user_id => user.id)
    create(:book, :user_id => user.id)
    
    user.last_tombo.should == 3
    
    user2 = create(:user)
    create(:book, :user_id => user2.id)
    user2.last_tombo.should == 1
  end
  
  it "should have error if no name is given on create" do
    user = build(:user, :name => "")

    user.should_not be_valid
    user.should have(1).error_on(:name)
  end
  
  it "should have error if no username is given on create" do
    user = build(:user, :username => "")

    user.should_not be_valid
    user.should have(1).error_on(:username)
  end
  
  it "should have error if duplicated name is given on create" do
    user = build(:user, :name => create(:user).name)
    user.should_not be_valid    
    user.should have(1).error_on(:name)
  end
  
  it "should have error if duplicated name is given on edit" do
    user = create(:user)
    user.name = create(:user).name
    
    user.should_not be_valid    
    user.should have(1).error_on(:name)
  end
  
  it "should have error if duplicated username is given on create" do
    user = build(:user, :username => create(:user).username)
    
    user.should_not be_valid
    user.should have(1).error_on(:username)
  end
  
  it "should have error if password is too small on create" do
    user = build(:user, :password => "small")
    
    user.should_not be_valid
    user.should have(1).error_on(:password)
  end
  
  it "should have error if password is too small on edit" do
    user = create(:user)
    user.password = "small"
    user.password_confirmation = user.password
    
    user.should_not be_valid
    user.should have(1).error_on(:password)
  end
  
    it "should have error if no password given on create" do
    user = build(:user, :password => "")
    
    user.should_not be_valid
    user.should have(1).error_on(:password)
  end
  
  it "should have no error if no password given on edit" do
    user = create(:user)
    user.password = ""
    user.password_confirmation = user.password
    
    user.should be_valid
  end
  
  it "should have error if confirmation doesn't match the password on create" do
    user = build(:user, :password => "secret", :password_confirmation => "wrong_pass")
    
    user.should_not be_valid
    user.should have(1).error_on(:password)
  end
  
  it "should have error if confirmation doesn't match the password on edit" do
    user = create(:user)
    user.password = "secret"
    user.password_confirmation = "wrong_secret"
          
    user.should_not be_valid
    user.should have(1).error_on(:password)
  end
  
  it "should have error with invalid username on create" do
    user = build(:user, :username => "foo bar")
    
    user.should_not be_valid
    user.should have(1).error_on(:username)
    
    user = build(:user, :username => "foo_bar/")
    
    user.should_not be_valid
    user.should have(1).error_on(:username)
    
    user = build(:user, :username => "")
    
    user.should_not be_valid
    user.should have(1).error_on(:username)
  end
  
  it "should return books" do
    user = create(:user)
    book = create(:book, :user_id => user.id)  

    user.books.count.should == 1
    user.books.first.should == book
  end
  
  it "should create folder before save" do
    user = create(:user)
    FileTest::directory?("public/backups/#{user.username}").should be_true
  end

end
