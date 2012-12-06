require File.dirname(__FILE__) + '/../spec_helper'

describe BooksController do
  describe "routing" do
    
    it '/:user_id/new to Book#new as new_user_book' do
      user = create(:user, :username => 'foo_bar')
      path = new_user_book_path(user)
      path.should == "/#{user.username}/new"
      { :get => path }.should route_to(
        :controller => 'books',
        :action => 'new',
        :user_id => user.username
      )
    end

    it '/:user_id/:id/edit to Book#edit as edit_user_book' do
      create(:book)
      user = create(:user, :username => 'foo_bar')
      book = create(:book, :user_id => user.id)
      path = edit_user_book_path(user, book)
      path.should == "/#{user.username}/#{book.tombo}/edit"
      { :get => path }.should route_to(
        :controller => 'books',
        :action => 'edit',
        :user_id => user.username,
        :id => book.tombo
      )
    end

    it '/:user_id/:book_id to Book#show as user_book' do
      create(:book)
      user = create(:user, :username => 'foo_bar')
      book = create(:book, :user_id => user.id)
      path = user_book_path(user, book)
      path.should == "/#{user.username}/#{book.tombo}"
      { :get => path }.should route_to(
        :controller => 'books',
        :action => 'show',
        :user_id => user.username,
        :id => book.tombo
      )
    end      
    
    it '/:user_id to Book#index as user_books' do
      user = create(:user, :username => 'foo_bar')
      path = user_books_path(user) 
      path.should == "/#{user.username}"
      { :get => path }.should route_to(
        :controller => 'books',
        :action => 'index',
        :user_id => user.username
      )
    end
      
    it '/books to Book#index as books' do
      path = books_path 
      path.should == "/books"
      { :get => path }.should route_to(
        :controller => 'books',
        :action => 'index'
      )
    end
    
    it '/ to Book#index as root' do
      path = root_path 
      path.should == "/"
      { :get => path }.should route_to(
        :controller => 'books',
        :action => 'index'
      )
    end
    
  end
end
