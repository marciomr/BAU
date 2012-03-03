# coding: utf-8

require 'spec_helper'

feature "Simple search", %q{
  In order to have an awesome library
  As an guest
  I should not be able to search books 
} do
  
  scenario "simple book search" do
    titles = ['Primeiro', 'Segundo', 'Terceiro']
        
    for title in titles do
      Factory(:book, :title => title)
    end
        
    visit books_path
    fill_in "search", :with => 'Prim'
    click_button "Busca"

    page.should have_content('Primeiro')
    for title in titles[1..-1] do
      page.should have_no_content(title)
    end
  end
  
  scenario "search in root" do
    titles = ['Primeiro', 'Segundo', 'Terceiro']
      
    for title in titles do
      Factory(:book, :title => title)
    end
        
    visit root_path
  
    for title in titles do
      page.should have_content(title)
    end
  end
  
end

feature "Advanced search", %q{
  In order to have an awesome library
  As an guest
  I should be able to make advanced searches  
} do

  scenario "without javascript" do
    Factory(:book, :title => "Sem PDF") 
    Factory(:book, :title => "Com PDF", :pdflink => "http://www.example.com")
    visit books_path
    
    click_link "busca avançada"
    
    check "pdf_filter"
    click_button "Busca"
    
    page.should have_content "Com PDF"
    page.should have_no_content "Sem PDF"  
  end
  
  scenario "PDF filter", :js => true do
    Factory(:book, :title => "Sem PDF") 
    Factory(:book, :title => "Com PDF", :pdflink => "http://www.example.com")
    visit books_path
    
    page.should have_no_content "Língua"
    click_link "busca avançada"
    wait_until do
      page.should have_content "Língua"
    end
    check "pdf_filter"
    click_button "Busca"
    
    page.should have_content "Com PDF"
    page.should have_no_content "Sem PDF" 
  end
  
  scenario "Language filter", :js => true do
    Factory(:book, :title => "English", :language => 'en') 
    Factory(:book, :title => "Portuguese", :language => 'pt')
    visit books_path
    
    page.should have_no_content "Língua"
    click_link "busca avançada"
    wait_until do
      page.should have_content "Língua"
    end
    select "en", :from => 'language_filter[]'
    click_button "Busca"
    
    page.should have_content "English"
    page.should have_no_content "Portuguese" 
  end
  
end
