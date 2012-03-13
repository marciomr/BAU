# coding: utf-8

require 'spec_helper'
  
feature "Autocomplete", %q{
  As logged user
  Repeated fields should autocomplete in forms
} do
  
  background do
    @user = create(:user)
    login(@user)
  end

  scenario "autocomplete without duplication", :js do
    create(:book, :editor => "Autocomplete")
    create(:book, :editor => "Autocomplete")
    
    visit new_user_book_path(@user)
    fill_in "book_editor", :with => 'Aut'

    sleep 5
    page.should have_css('li.ui-menu-item', :count => 1)
  end
  
  scenario "autocomplete tag", :js do
    create(:book, :tags => [create(:tag, :title => "Autocomplete")] )
    
    visit new_user_book_path(@user)
    click_link 'Adicionar palavra chave'      
    fill_in "Palavra Chave", :with => 'Aut'
    
    sleep 5
    page.should have_content('Autocomplete')
  end
    
  scenario "autocomplete author", :js do
    create(:book, :authors => [create(:author, :name => "Autocomplete")] )
    
    visit new_user_book_path(@user)
    fill_in "Autor", :with => 'Aut'
    
    sleep 5
    page.should have_content('Autocomplete')
  end
  
  scenario "autocomplete", :js do   
   for attribute in ['editor', 'subject', 'collection', 'city', 'country'] do
      create(:book, attribute => 'Autocomplete')

      visit new_user_book_path(@user)
      fill_in "book_#{attribute}", :with => 'Aut'
      sleep 5  
      page.should have_content('Autocomplete')
    end
  end
  
end
