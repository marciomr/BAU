# coding: utf-8

require 'spec_helper'

feature "Simple search", %q{
  As an guest
  I should be able to search books 
} do
  
  background do
    create(:admin)
  end
  
  scenario "simple title search", :focus do
    ['Primeiro', 'Segundo'].each do |title|
      create(:book, :title => title)
    end
        
    visit books_path
    fill_in "search", :with => 'Prim'
    submit_form('simple_search') 

    page.should have_content('Primeiro')
    page.should_not have_content('Segundo')
  end
  
  scenario "simple title search in user page", :focus do
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
end

feature "Advanced search", %q{
  As an guest
  I should be able to make advanced searches  
} do

  background do
    create(:admin)
  end

  scenario "PDF filter without javascript" do
    create(:book, :title => "No PDF", :pdflink => '') 
    create(:book, :title => "With PDF", :pdflink => "http://www.example.com")
    visit books_path

    click_link "busca avançada"
    
    check "pdf_filter"
    click_button "Busca"

    page.should have_content "With PDF"
    page.should_not have_content "No PDF"  
  end
  
  scenario "PDF filter with javascript", :js do
    create(:book, :title => "No PDF", :pdflink => '') 
    create(:book, :title => "With PDF", :pdflink => "http://www.example.com")
    visit books_path
    
    page.should have_no_content "Língua"
    click_link "busca avançada"
  
    sleep 1

    page.should have_content "Língua"
    check "pdf_filter"
    click_button "Busca"
    
    page.should have_content "With PDF"
    page.should_not have_content "No PDF"
  end
  
  scenario "Language filter without javascript" do
    create(:book, :title => "English", :language => 'en') 
    create(:book, :title => "Portuguese", :language => 'pt')
    visit books_path
    
    click_link "busca avançada"
    
    select "en", :from => 'language_filter[]'
    click_button "Busca"
    
    page.should have_content "English"
    page.should_not have_content "Portuguese" 
  end

  scenario "Author filter without javascript" do
    create(:book, :title => 'Title', :authors => [create(:author, :name => 'First')]) 
    create(:book, :title => 'First', :authors => [create(:author, :name => 'Second')])
    visit books_path
    
    click_link "busca avançada"
    
    fill_in 'author_filter', :with => 'First'
    click_button "Busca"
    
    page.should have_content "Title"
    page.should_not have_content "Second" 
  end
  
  scenario "Title filter without javascript" do
    create(:book, :title => 'First', :authors => [create(:author, :name => 'Author')]) 
    create(:book, :title => 'Second', :authors => [create(:author, :name => 'First')])
    visit books_path
    
    click_link "busca avançada"
    
    fill_in 'title_filter', :with => 'First'
    click_button "Busca"
    
    page.should have_content "First"
    page.should_not have_content "Second" 
  end
  
  scenario "Editor filter without javascript" do
    create(:book, :title => 'Title', :editor => 'First') 
    create(:book, :title => 'First', :editor => 'Second')
    visit books_path
    
    click_link "busca avançada"
    
    fill_in 'editor_filter', :with => 'First'
    click_button "Busca"
    
    page.should have_content "Title"
    page.should_not have_content "First" 
  end
end
