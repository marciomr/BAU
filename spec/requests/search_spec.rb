# coding: utf-8

require 'spec_helper'

feature "Simple search", %q{
  As an guest
  I should be able to search books 
} do
  
  background do
    create(:admin)
  end
  
  scenario "simple title search" do
    ['Primeiro', 'Segundo'].each do |title|
      create(:book, :title => title)
    end
        
    visit books_path
    fill_in "search", :with => 'Prim'
    submit_form('simple_search') 

    page.should have_content('Primeiro')
    page.should_not have_content('Segundo')
  end
  
  scenario "simple title search in user page" do
    user = create(:user)        
    ['Primeiro', 'Segundo'].each do |title|
      create(:book, :title => title, :user => user)
    end
        
    visit user_books_path(user)
    fill_in "search", :with => 'Prim'
    submit_form('simple_search')

    page.should have_content('Primeiro')
    
    visit user_books_path(create(:user))
    fill_in "search", :with => 'Prim'
    submit_form('simple_search')
    
    page.should_not have_content('Primeiro')
  end
  
  scenario "simple search various attributes" do
    create(:book, :title => 'With Title')
    create(:book, :authors => [create(:author, :name =>'With Author')])
    create(:book, :title => 'Tag', :tags => [create(:tag, :title => 'With')])
    create(:book, :title => 'No Title')
    create(:book, :authors => [create(:author, :name =>'No Author')])
    create(:book, :tags => [create(:tag, :title => 'No Tag')])

    visit books_path
    fill_in "search", :with => 'With'
    submit_form('simple_search')    
    
    page.should have_content('With Title')
    page.should have_content('Tag')
    page.should have_content('With Author')
    
    page.should_not have_content('No Title')
    page.should_not have_content('No Tag')
    page.should_not have_content('No Author')
  end

  scenario "Accent search" do
    ['Primeiro', 'Prímeirô', 'Segundo'].each do |title|
      create(:book, :title => title)
    end
        
    visit books_path
    fill_in "search", :with => 'Prim'
    submit_form('simple_search') 

    page.should have_content('Primeiro')
    page.should have_content('Prímeirô')
    page.should_not have_content('Segundo')
    
  end

end

feature "Advanced search", %q{
  As an guest
  I should be able to make advanced searches  
} do

  background do
    create(:admin)
  end

  scenario "PDF filter" do
    create(:book, :title => "No PDF", :pdflink => '') 
    create(:book, :title => "With PDF", :pdflink => "http://www.example.com")
    visit books_path

    check "pdf_filter"
    click_button "Busca"

    page.should have_content "With PDF"
    page.should_not have_content "No PDF"  
  end
  
  scenario "Language filter" do
    create(:book, :title => "English", :language => 'en') 
    create(:book, :title => "Portuguese", :language => 'pt')
    visit books_path
    
    select "en", :from => 'language_filter[]'
    click_button "Busca"
    
    page.should have_content "English"
    page.should_not have_content "Portuguese" 
  end

  scenario "Author filter" do
    create(:book, :title => 'Title', :authors => [create(:author, :name => 'First')]) 
    create(:book, :title => 'First', :authors => [create(:author, :name => 'Second')])
    visit books_path
    
    fill_in 'author_filter', :with => 'First'
    click_button "Busca"
    
    page.should have_content "Title"
    page.should_not have_content "Second" 
  end
  
  scenario "Title filter" do
    create(:book, :title => 'First', :authors => [create(:author, :name => 'Author')]) 
    create(:book, :title => 'Second', :authors => [create(:author, :name => 'First')])
    visit books_path
    
    fill_in 'title_filter', :with => 'First'
    click_button "Busca"
    
    page.should have_content "First"
    page.should_not have_content "Second" 
  end
  
  scenario "Editor filter" do
    create(:book, :title => 'Title', :editor => 'First') 
    create(:book, :title => 'First', :editor => 'Second')
    visit books_path
    
    fill_in 'editor_filter', :with => 'First'
    click_button "Busca"
    
    page.should have_content "Title"
    page.should_not have_content "First" 
  end
  
  scenario "Search with filter" do
    create(:book, :title => 'First', :authors => [create(:author, :name => 'Author')])
    create(:book, :title => 'Second', :authors => [create(:author, :name => 'First')])
    create(:book, :title => 'Third', :authors => [create(:author, :name => 'Author')])
    
    visit books_path
    fill_in "search", :with => 'First'
    submit_form('simple_search')    
    
    page.should have_content 'First'
    page.should have_content 'Second'
    page.should_not have_content 'Third'
    
    fill_in 'author_filter', :with => 'Author'
    click_button "Busca"
        
    page.should have_content 'First'
    page.should_not have_content 'Second'
    page.should_not have_content 'Third' 
  end
  
  scenario "Filter Library" do
    users = [create(:user), create(:user)]
    books = [create(:book, :title => 'First', :user => users[0]), create(:book, :title => 'Second', :user => users[1])]
    
    visit books_path
    
    select users[0].name, :from => 'user_filter[]'
    
    click_button "Busca"
    
    page.should have_content books[0].title
    page.should_not have_content books[1].title
  end
  
end 
