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
  
  scenario "autocomplete tag", :js => true do
    Factory(:book, :tags => [Factory(:tag, :title => "Autocomplete")] )
    
    visit new_book_path
    click_link 'Add Tag'      
    fill_in "Palavra Chave", :with => 'Aut'
    
    wait_until do
      page.should have_content('Autocomplete')
    end
  end
    
  scenario "autocomplete author", :js => true do
    Factory(:book, :authors => [Factory(:author, :name => "Autocomplete")] )
    
    visit new_book_path
    fill_in "Autor", :with => 'Aut'
    
    wait_until do
      page.should have_content('Autocomplete')
    end
  end
  
  scenario "autocomplete", :js => true do
    for attribute in ['editor', 'subject', 'collection', 'city', 'country'] do
      Factory(:book, attribute => 'Autocomplete')

      visit new_book_path
      fill_in "book_#{attribute}", :with => 'Aut'
        
      wait_until do
        page.should have_content('Autocomplete')
      end
    end
  end
  
end
