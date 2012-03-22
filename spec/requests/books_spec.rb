# coding: utf-8

require 'spec_helper'

feature "Manage books as logged user without js", %q{
  As an logged user
  I want to create and manage my books even wihout javascript
} do

  background do
    create(:admin)
    @user = create(:user)
    login(@user)
  end

  scenario "create a book with all atributes" do
    visit new_user_book_path(@user)
    
    book = build(:book)
    author = create(:author)
    
    fields = %w(title subtitle year page_number description editor)
    fields += %w(subject language volume city country pdflink imglink cdd)
    fields.each do |f|
      fill_in "book[#{f}]", :with =>book.send(f)
    end

    fill_in "Autor", :with => author.name
    
    lambda do
      click_button "Salvar"
    end.should change(@user.books, :count).by(1)
            
    page.should have_flash_notice
    
    (fields - %w(pdflink imglink)).each do |f|
      page.should have_content(book.send(f))
    end  
    page.should have_content(author.name) 
    page.should have_link_to(book.pdflink)
    page.should have_img(book.imglink)
  end

  scenario "create a book with wrong pdf" do
    visit new_user_book_path(@user)

    lambda do
      fill_in "Título", :with => 'Title'
      fill_in "PDF", :with => 'wrong link'
      click_button 'Salvar'
    end.should_not change(Book, :count)
      
    page.should have_content "Link inválido."
  end

  scenario "create book with isbn" do
    faweb_register_book('gbook-empty.xml', '1234567890')
    visit new_user_book_path(@user)
    
    fill_in "ISBN", :with => 1234567890
    click_button "Preencher"
    
    fill_in "Título", :with => "Título"
    click_button "Salvar"

    page.should have_content("1234567890")
  end
  
  scenario "edit own book" do
    author = create(:author)
    book = create(:book, :title => "Lorem Ipsum", :authors => [author], :user => @user)
    visit edit_user_book_path(@user, book)
    
    find(:field, 'book_title').value.should have_content(book.title)
    find(:css, '.book_authors').value.should have_content(author.name)
    # seria bom testar se os autores aparecem
    fill_in "ISBN", :with => 123
    fill_in "Título", :with => "A Conquista do Pão"
      
    click_button "Salvar"
    
    current_path.should == user_book_path(@user, book)
    
    page.should have_flash_notice
    page.should have_content("A Conquista do Pão")
    page.should have_content("123")
  end  

  # esse deveria estar no view test    
  scenario "see own book edit link in index" do
    book = create(:book, :user => @user)
      
    visit books_path
    
    page.should have_content "Editar"
    
    click_link "Editar"
    current_path.should == edit_user_book_path(book.user, book)
  end  
  
  # esse deveria estar no view test  
  scenario "see own book edit link in show" do
    book = create(:book, :user => @user)
    
    visit user_book_path(@user, book)
    
    page.should have_content "Editar"
    
    click_link "Editar"
    current_path.should == edit_user_book_path(@user, book)
  end  
  
  # esse deveria estar no view test  
  scenario "don't see other user's book edit link in index" do
    user = create(:user)
    book = create(:book, :user => user)
    
    @user.admin?.should be_false
    visit user_book_path(user, book)
   
    page.should_not have_content "Editar"
  end    
  
  # esse deveria estar no view test  
  scenario "don't see other's book edit link in show" do
    user = create(:user)
    book = create(:book, :user => user)
    
    visit user_book_path(user, book)
    
    page.should_not have_content "Editar"
  end    
    
  scenario "delete own book in index" do
    create(:book, :user => @user)
    
    visit books_path
    
    lambda do
      click_link "Deletar"
    end.should change(@user.books, :count).by(-1)
    
    current_path.should == user_books_path(@user)
    page.should have_flash_notice
  end  
  
  scenario "delete own book in show" do
    book = create(:book, :user => @user)
    
    visit user_book_path(@user, book)

    lambda do
      click_link "Deletar"
    end.should change(@user.books, :count).by(-1)
    
    page.should have_flash_notice
  end    
end

feature "Manage Books as Admin", %q{
  As an admin
  I want to manage any book even wihout javascript
} do

  background do
    @admin = create(:admin)
    login(@admin)
  end

  scenario "create a book" do
    user = create(:user)
    visit new_user_book_path(user)
    
    lambda do
      fill_in 'Título', :with => "Título"
      click_button "Salvar"
    end.should change(user.books, :count).by(1)   
    
    page.should have_flash_notice
    page.should have_content("Título")
  end
  
  scenario "don't create book for admin" do
    visit new_user_book_path(@admin)
    
    current_path.should == root_path
    page.should have_flash_alert
  end
  
  scenario "edit any book" do
    author = create(:author)
    book = create(:book, :title => "Lorem Ipsum", :authors => [author])
    visit edit_user_book_path(book.user, book)
    
    find(:field, 'book_title').value.should have_content(book.title)
    find(:css, '.book_authors').value.should have_content(author.name)
    
    fill_in "Título", :with => "A Conquista do Pão"
      
    click_button "Salvar"
    page.should have_flash_notice
    page.should have_content("A Conquista do Pão")
  end  
  
  scenario "see book edit link in index" do
    book = create(:book)
      
    visit user_books_path(book.user)
    
    page.should have_content "Editar"
    
    click_link "Editar"
    current_path.should == edit_user_book_path(book.user, book)
  end  
  
  scenario "delete any book" do
    create(:book)
    
    visit books_path
    
    lambda do
      click_link "Deletar"
    end.should change(Book, :count).by(-1)  
    
    page.should have_flash_notice
  end  
end

feature "Manage books as guest", %q{
  As an guest
  I want not to be allowed to manage any book
} do

  background do
    create(:admin)
    @user = create(:user)
  end

  # deveria testar no view
  scenario "don't see book edit link in index" do
    book = create(:book, :user => @user)
    
    visit user_book_path(@user, book)
    
    page.should_not have_content "Editar"
  end    
    
  # deveria testar no view  
  scenario "don't see book edit link in show" do
    book = create(:book, :user => @user)
    
    visit user_book_path(@user, book)
    
    page.should_not have_content "Editar"
  end    

  # deveria testar no view
  scenario "don't see delete book link" do
    user = create(:user)
    create(:book, :user => user)
    
    visit books_path
    
    page.should_not have_content "Deletar"
  end    
end

feature "Display Books", %q{
  As guest
  I want to see books list and books content
} do
  
  background do
    create(:admin)
    @user = create(:user)
    @book = create(:book, :user => @user)
  end
  
  scenario "RSS content" do
    visit books_path(:rss)
      
    page.should have_content(@book.title)
  end
  
  scenario "display books list" do
    visit books_path
  
    page.should have_content(@book.title)
  end
  
  scenario "display user's books list" do
    visit user_books_path(@user)
  
    page.should have_content(@book.title)
  end
  
  scenario "see book's detail" do
    visit user_book_path(@user, @book)
    
    fields = %w(tombo isbn title subtitle year page_number description)
    fields += %w(editor subject language volume city country cdd)
    
    fields.each do |f|
      page.should have_content(@book.send(f))
    end
    page.should have_link_to(@book.pdflink)
    page.should have_img(@book.imglink)
  end
  
  scenario "don't display other user's book" do
    visit user_books_path(create(:user))
    
    page.should_not have_content(@book.title)
  end
end


