# coding: utf-8

require 'spec_helper'

feature "Pagination", %q{
  In order to have an awesome library
  As an guest
  I want to display books in pages
} do
  
  scenario "pagination" do
    41.times{ Factory(:book) }
    visit books_path
    
    page.should have_content "Next"
    [1..3].each{ |n| page.should have_link "#{1}"}
    
    click_link "Next"
    page.should have_content "Next"
    [1..3].each{ |n| page.should have_link "#{1}"}
  end

  scenario "pagination with few books" do
    Factory(:book)
    visit books_path
    
    page.should have_no_content "Next"
  end
  
end
