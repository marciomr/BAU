# coding: utf-8

require 'spec_helper'

feature "Login and logout", %q{
  I should be able to login and logout 
} do

  background do
    create(:admin)
    @user = create(:user, :password => 'secret')
  end

  scenario "login successfully via login page" do
    visit login_path
    
    within('#main-div') do
      fill_in "Usuário", :with => @user.username
      fill_in "Senha", :with => @user.password
    
      click_button "Entrar"  
    end    
     
    page.should have_flash_notice
  end
  
  scenario "login unsuccessfully via login page" do
    visit login_path
    
    within('#main-div') do
      fill_in "Usuário", :with => @user.username
      fill_in "Senha", :with => "wrong_pass"
    
      click_button "Entrar"
    end
    
    page.should have_flash_alert
  end

  scenario "login successfully via modal" do
    visit root_path
    click_link 'Login'
    
    fill_in "Usuário", :with => @user.username
    fill_in "Senha", :with => @user.password
    
    click_button "Entrar"  
     
    page.should have_flash_notice
  end
  
  scenario "login unsuccessfully via modal" do
    visit root_path
    click_link 'Login'
    
    fill_in "Usuário", :with => @user.username
    fill_in "Senha", :with => "wrong_pass"
    
    click_button "Entrar"
    
    page.should have_flash_alert
  end

  scenario "logout" do
    login(@user)
    click_link 'Logout'
    
    page.should have_flash_notice
  end
end

feature "Access Restriction", %q{
  The guest access should be restricted
} do

  background do
    create(:admin)
    @user = create(:user, :password => 'secret')
  end

  scenario "redirect if guest try to enter new book page" do
    visit new_user_book_path(@user)

    page.should have_flash_alert
    current_path.should == login_path
  end
  
  scenario "redirect back to new book page" do
    visit new_user_book_path(@user)
    login(@user)
    
    current_path.should == new_user_book_path(@user)
  end
  
  scenario "redirect if guest try to enter edit book page" do
    visit edit_user_book_path(@user, create(:book, :user => @user))
    
    page.should have_flash_alert
    current_path.should == login_path    
  end
  
  scenario "redirect back to edit book page" do
    book = create(:book, :user => @user)
    visit edit_user_book_path(@user, book)

    login(@user)
    
    current_path.should == edit_user_book_path(@user, book)
  end
  
  scenario "redirect if try to edit user profile" do
    visit edit_user_path(create(:user))
    
    page.should have_flash_alert    
    current_path.should == login_path
  end
  
  scenario "redirect back to user edit page" do
    user = create(:user)
    visit edit_user_path(user)
    
    within '#main-div' do
      fill_in "Usuário", :with => user.username
      fill_in "Senha", :with => user.password
      click_button "Entrar"   
    end  
   
    current_path.should == edit_user_path(user)
  end
  
end
