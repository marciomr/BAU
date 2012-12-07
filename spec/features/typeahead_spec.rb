# coding: utf-8

require 'spec_helper'
  
feature "Autocomplete", %q{
  As logged user
  Repeated fields should autocomplete in forms
} do
  
  background do
    create(:admin)
    @user = create(:user)
    login(@user)
  end

  scenario "autocomplete tag", :js do
    create(:book, :tags => [create(:tag, :title => "Autocomplete")], :user => @user)
    create(:book, :tags => [create(:tag, :title => "Auto")])
    create(:book, :tags => [create(:tag, :title => "Not")])
      
    visit new_user_book_path(@user)
    click_link 'Adicionar palavra chave'
    fill_in "Palavra Chave", :with => 'Aut'
    
    sleep 1
    
    page.should have_content('Auto')
    page.should have_content('Autocomplete')
    page.should_not have_content('Not')
  end
    
  scenario "autocomplete author", :js do
    create(:book, :authors => [create(:author, :name => "Autocomplete")], :user => @user)
    create(:book, :authors => [create(:author, :name => "Auto")])
    create(:book, :authors => [create(:author, :name => "Not")])
      
    visit new_user_book_path(@user)
    fill_in "Autor", :with => 'Aut'
    
    sleep 1
    
    page.should have_content('Auto')
    page.should have_content('Autocomplete')
    page.should_not have_content('Not')
  end
  
  scenario "autocomplete", :js do   
   %w(editor subject city country).each do |field|
      create(:book, field.to_sym => 'Autocomplete', :user => @user)
      create(:book, field.to_sym => 'Auto')
      create(:book, field.to_sym => 'Not')

      visit new_user_book_path(@user)
      fill_in "book_#{field}", :with => 'Aut'
      
      sleep 1
        
      page.should have_content('Auto')
      page.should have_content('Autocomplete')
      page.should_not have_content('Not')
    end
  end
  
end
