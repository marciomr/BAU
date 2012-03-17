# coding: utf-8

require 'spec_helper'

feature "Pagination", %q{
  As an guest
  I want to display books in pages
} do

  background do
    create(:admin)
  end
  
  scenario "pagination" do
    41.times{ create(:book) }
    visit books_path
    
    page.should have_content "Next"
    [1..3].each{ |n| page.should have_link "#{1}"}
    
    click_link "Next"
    page.should have_content "Next"
    [1..3].each{ |n| page.should have_link "#{1}"}
  end

  scenario "pagination with few books" do
    create(:book)
    visit books_path
    
    page.should have_no_content "Next"
  end
  
end
