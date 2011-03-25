# coding: utf-8

require 'spec_helper'

feature "Google Book search and form complete", %q{
  In order to have an awesome library
  As an admin
  When the book exists in google books the form should complete itself
} do

  background do
    login
  end
  
  scenario "google books", :js => true do
    visit new_book_path
    fill_in "isbn", :with => 1606802127
    click_button "Preencher"
    
    click_button "Salvar"
    
    page.should have_content "What Is Property"
    page.should have_content "An Inquiry Into The Principle Of Right And Of Government"
    page.should have_content "Pierre Joseph Proudhon"
    page.should have_content "Amédée Jérôme Langlois"
    page.should have_content "Forgotten Books"
    page.should have_content "1969"
    page.should have_content "en"
    page.should have_content "446"
  end
end
