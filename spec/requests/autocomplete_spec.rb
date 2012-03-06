# coding: utf-8

require 'spec_helper'

feature "Autocomplete", %q{
  In order to have an awesome library
  As an admin
  Repeated fields should autocomplete in forms
} do
  
  background do
    login
  end

  scenario "autocomplete without duplication", :js do
    Factory(:book, :editor => "Autocomplete")
    Factory(:book, :editor => "Autocomplete")
    
    visit new_book_path
    fill_in "book_editor", :with => 'Aut'

    sleep 5
    page.should have_css('li.ui-menu-item', :count => 1)
  end
  
  scenario "autocomplete tag", :js do
    Factory(:book, :tags => [Factory(:tag, :title => "Autocomplete")] )
    
    visit new_book_path
    click_link 'Add Tag'      
    fill_in "Palavra Chave", :with => 'Aut'
    
    sleep 5
    page.should have_content('Autocomplete')
  end
    
  scenario "autocomplete author", :js do
    Factory(:book, :authors => [Factory(:author, :name => "Autocomplete")] )
    
    visit new_book_path
    fill_in "Autor", :with => 'Aut'
    
    sleep 5
    page.should have_content('Autocomplete')
  end
  
  scenario "autocomplete", :js do   
   for attribute in ['editor', 'subject', 'collection', 'city', 'country'] do
      Factory(:book, attribute => 'Autocomplete')

      visit new_book_path
      fill_in "book_#{attribute}", :with => 'Aut'
      sleep 5  
      page.should have_content('Autocomplete')
    end
  end
  
end
