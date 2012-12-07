# coding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

feature "Auto-fill form", %q{
  In order to have an awesome library
  As a logged user
  When the book exists in google books or in the library the form should be auto-filled
  } do

  background do
    create(:admin)
    @user = create(:user)
    login(@user)
  end

  scenario "google books without javascript" do
    faweb_register_book('gbook-proudhon.xml', '1606802127')
    google_book_test
    all(:css, '.book_authors').first.value.should have_content("Pierre Joseph Proudhon")
  end
  
  scenario "google books with javascript", :js do
    google_book_test
    all(:css, '.book_authors').last.value.should have_content("Pierre Joseph Proudhon")
  end
  
  scenario "auto-fill with other user's books without javascript" do
    faweb_register_book('gbook-empty.xml', '1234567890')
    book = create(:book, :isbn => 1234567890)
    auto_fill_test(book)
    all(:css, '.book_authors').first.value.should have_content(book.authors.first.name)
  end
  
  scenario "auto-fill with other user's books with javascript", :js do
    book = create(:book, :isbn => 1234567890)
    auto_fill_test(book)
    all(:css, '.book_authors').last.value.should have_content(book.authors.first.name)
  end
end

def auto_fill_test(book)
  author = create(:author, :book_id => book.id)
  visit new_user_book_path(@user)
    
  fill_in "isbn", :with => book.isbn
  click_button "Preencher"

  sleep 3
  
  %w(title subtitle country city).each do |f|
    find(:field, "book_#{f}").value.should have_content(book.send(f))
  end
end

def google_book_test
  visit new_user_book_path(@user)
  fill_in "isbn", :with => 1606802127
  click_button "Preencher"
  
  sleep 3
  
  find(:field, 'book_title').value.should have_content("What Is Property")
  find(:field, 'book_subtitle').value.should have_content("An Inquiry Into The Principle Of Right And Of Government")
  find(:field, 'book_editor').value.should have_content("Forgotten Books")
  find(:field, 'book_language').value.should have_content("En")
  find(:field, 'book_page_number').value.should have_content("457")
end

