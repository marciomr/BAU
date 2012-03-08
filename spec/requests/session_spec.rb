# coding: utf-8

require 'spec_helper'

feature "Guest Account", %q{
  In order to have an awesome library
  As an guest
  I should not be able to create or edit books 
} do

  scenario "login successfully" do
    user = create(:user)
    visit login_path
    
    fill_in "Usuário", :with => user.username
    fill_in "Senha", :with => user.password
    
    click_button "Entrar"
    
    page.should have_flash_notice_with("Logado!")
    page.should have_content("Deslogar")
  end
  
  scenario "login unsuccessfully" do
    user = create(:user, :password => "secret")
    visit login_path
    
    fill_in "Usuário", :with => user.username
    fill_in "Senha", :with => "wrong_pass"
    
    click_button "Entrar"
    
    page.should have_flash_alert_with("Senha ou usuário invalido!")
    
    visit root_path
    page.should_not have_content(user.name)
    page.should have_content("Logar")
  end
  
end
  
#  scenario "not enter new book page as guest" do
#    visit new_book_path
#      
#    page.should have_content "Acesso negado"
#    current_path.should == login_path
#  end

#  scenario "not enter edit book page as guest" do
#    visit edit_book_path(Factory(:book))
#      
#    page.should have_content "Acesso negado"
#    current_path.should == login_path
#  end
#  
#  scenario "logging in" do
#    visit login_path
#    
#    fill_in "password", :with => APP_CONFIG['password']
#    click_button "Entrar"
#    
#    page.should have_content "Logado com sucesso"  
#  end
#  
#  scenario "returns to page after logging in" do
#    visit new_book_path
#      
#    fill_in "password", :with => APP_CONFIG['password']
#    click_button "Entrar"
#      
#    current_path.should == new_book_path
#    page.should have_content("Logado com sucesso") 
#  end
#end

#feature "Admin Account", %q{
#  In order to have an awesome library
#  As an admin
#  I should be able to create or edit books 
#} do
#  
#  background do
#    login
#  end
#  
#  scenario "enter new book page as admin" do
#    visit new_book_path
#      
#    current_path.should == new_book_path
#  end

#  scenario "enter edit book page as admin" do
#    book = Factory(:book)
#    visit edit_book_path(book)
#      
#    current_path.should == edit_book_path(book)
#  end
#  
#  scenario "see links as admin" do
#    visit books_path   
#    page.should have_content("Deslogar")
#    page.should have_content("Novo Livro")
#    
#    click_link "Novo Livro"
#    current_path.should == new_book_path     
#  end
#  
#  scenario "log out" do
#    visit books_path
#    click_link "Deslogar"
#    page.should have_content("Deslogado com sucesso") 
#    
#    visit new_book_path
#      
#    page.should have_content "Acesso negado"
#    current_path.should == login_path
#  end
#end
