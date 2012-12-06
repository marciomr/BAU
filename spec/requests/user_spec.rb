# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'
#require 'spec_helper'

feature "User edit own profile", %q{
  As logged user
  One may edit own profile
} do

  background do
    create(:admin)
    @user = create(:user)
    login(@user)
  end
  
  scenario "edit own profile" do
    visit edit_user_path(@user)
    
    find(:field, 'user_name').value.should have_content(@user.name)
    find(:field, 'user_password').value.should be_blank
    find(:field, 'user_password_confirmation').value.should be_blank
    find(:field, 'user_description').value.should have_content(@user.description)
    
    fill_in "Nome", :with => "Foo Bar"
    click_button "Salvar"
    
    page.should have_flash_notice # flash not working
    page.should have_content("Foo Bar")
    page.should have_content(@user.username)
  end
  
  scenario "redirect if try to edit other user's profile" do
    user = create(:user)
    visit edit_user_path(user)
    
    page.should have_flash_alert    
    current_path.should == login_path
  end
end

feature "Admin manage users", %q{
  As admin
  One may create user and edit any profile
} do
  
  background do
    @admin = create(:admin)
    login(@admin)
  end
  
  scenario "create user" do
    user = build(:user)
    visit signup_path
    
    within '#main-div' do
      lambda do    
        fill_in "Usuário", :with => user.username
        fill_in "Nome", :with => user.name
        fill_in "Senha", :with => user.password
        fill_in "Confirme a senha", :with => user.password
        fill_in "Descrição", :with => user.description
        click_button "Salvar"
      end.should change(User, :count).by(1)
    end
    
    page.should have_flash_notice
  end

  scenario "edit profile" do
    visit edit_user_path(create(:user))
    
    fill_in "Nome", :with => "Foo Bar"
    click_button "Salvar"

    page.should have_flash_notice    
    page.should have_content("Foo Bar")
  end

  scenario "remove user" do
    visit user_path(create(:user))

    lambda do  
      click_link "Remover"
    end.should change(User, :count).by(-1)
   
    page.should have_flash_notice  
  end
end
