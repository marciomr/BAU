# coding: utf-8

require 'spec_helper'

feature "Manage backups", %q{
  As an logged user
  I want to create and recover backups
} do

  background do
    create(:admin)
  end

  scenario "create a backup" do
#    user = create(:user)
#    login(user)
#    
#    visit user_backups_path(user)
#    click_link 'Criar Backup'

#    page.should have_flash_notice
    pending 
  end
  
  scenario "recover a backup" do
    pending
  end
  
  scenario "upload a file" do
    pending
  end
  
end
