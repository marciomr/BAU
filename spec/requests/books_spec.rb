# coding: utf-8

require 'spec_helper'

feature "Create Books", %q{
  In order to have an awesome library
  As an logged user
  I want to create and manage books even with js off
} do

# ATENCAO SEM JS NAUM CONSIGO SALVAR O ISBN

  background do
    @admin = create(:admin)
  end

  scenario "create a book with all atributes if logged" do
    user = create(:user)
    login(user)
    visit new_book_path
    
    book = build(:book)
    author = create(:author)
    fill_in "Título", :with => book.title
    fill_in "Subtítulo", :with => book.subtitle
    fill_in "Volume", :with => book.volume
    fill_in "Autor", :with => author
    fill_in "Editor", :with => book.editor
    fill_in "Ano", :with => book.year
    fill_in "Língua", :with => book.language
    fill_in "Número de Páginas", :with => book.page_number
    fill_in "Assunto", :with => book.subject
    fill_in "Acervo", :with => book.collection
    fill_in "Cidade", :with => book.city
    fill_in "País", :with => book.country
    fill_in "CDD", :with => book.cdd
    fill_in "Imagem", :with => book.imglink
    fill_in "PDF", :with => book.pdflink  
    fill_in "Descrição", :with => book.description
    
    click_button "Salvar"
        
    user.books.should have(1).record
    
    page.should have_content("Livro criado com sucesso.")
    
    page.should have_content(book.title) 
    page.should have_content(book.subtitle) 
    page.should have_content(book.tombo)
    page.should have_content(author) 
    page.should have_content(book.editor) 
    page.should have_content(book.year) 
    page.should have_content(book.language) 
    page.should have_content(book.page_number) 
    page.should have_content(book.subject) 
    page.should have_content(book.collection)
    page.should have_content(book.city) 
    page.should have_content(book.country) 
    page.should have_content(book.cdd) 
    page.should have_content(book.description) 
    page.should have_link_to(book.pdflink)
    page.should have_img(book.imglink)
  end
  
  scenario "don't create book with guest account" do
    visit new_book_path
    page.should have_flash_alert("Acesso negado!")
    current_path.should == login_path    
    
    login(create(:user))
    
    page.should have_flash_notice("Logado!")
    current_path.should == new_book_path
  end
  
  scenario "edit own book" do
    user = create(:user)
    login(user)
    
    author = create(:author, :name => "Kropotkin")
    book = create(:book, :title => "Lorem Ipsum", :authors => [author], :user => user)
    visit edit_book_path(book)
    
    find(:field, 'book_title').value.should have_content(book.title)
    find(:css, '.book_author').value.should have_content(author.name)
    
    fill_in "Título", :with => "A Conquista do Pão"
      
    click_button "Salvar"
    page.should have_flash_notice("Livro editado com sucesso")
    page.should have_content("A Conquista do Pão")
  end  
    
  scenario "edit book as admin" do
    login(@admin)
    
    author = create(:author, :name => "Kropotkin")
    book = create(:book, :title => "Lorem Ipsum", :authors => [author])
    visit edit_book_path(book)
    
    find(:field, 'book_title').value.should have_content(book.title)
    find(:css, '.book_author').value.should have_content(author.name)
    
    fill_in "Título", :with => "A Conquista do Pão"
      
    click_button "Salvar"
    page.should have_flash_notice("Livro editado com sucesso")
    page.should have_content("A Conquista do Pão")
  end  
    
  scenario "see own book edit link in index" do
    user = create(:user)
    book = create(:book, :user => user)
    login(user)
      
    visit books_path
    
    page.should have_content "Editar"
    
    click_link "Editar"
    current_path.should == edit_book_path(book)
  end  
  
  scenario "see book edit link in index as admin" do
    book = create(:book)
    login(@admin)
      
    visit books_path
    
    page.should have_content "Editar"
    
    click_link "Editar"
    current_path.should == edit_book_path(book)
  end  
    
  scenario "see own book edit link in show" do
    user = create(:user)
    book = create(:book, :user => user)
    login(user)
    
    visit book_path(book)
    
    page.should have_content "Editar"
    
    click_link "Editar"
    current_path.should == edit_book_path(book)
  end  
  
  scenario "don't see book edit link in index as guest" do
    user = create(:user)
    book = create(:book, :user => user)
    
    visit book_path(book)
    
    page.should_not have_content "Editar"
  end    
    
  scenario "don't see book edit link in show as guest" do
    user = create(:user)
    book = create(:book, :user => user)
    
    visit book_path(book)
    
    page.should_not have_content "Editar"
  end    
  
  scenario "don't see other user's book in index" do
    user = create(:user)
    book = create(:book, :user => user)
    login(create(:user))
    
    visit book_path(book)
    
    page.should_not have_content "Editar"
  end    
    
  scenario "don't see other's book in show" do
    user = create(:user)
    book = create(:book, :user => user)
    login(create(:user))
    
    visit book_path(book)
    
    page.should_not have_content "Editar"
  end    
    
  scenario "delete own book" do
    user = create(:user)
    create(:book, :user => user)
    login(user)
    
    visit books_path
    
    within(:css, "li:first-child") do
      click_button "Remover"
    end    
    
    page.should have_content "Livro deletado com sucesso"
    Book.should have(0).record
  end  
  
  scenario "delete book as admin" do
    create(:book)
    login(@admin)
    
    visit books_path
    
    within(:css, "li:first-child") do
      click_button "Remover"
    end    
    
    page.should have_content "Livro deletado com sucesso"
    Book.should have(0).record
  end  
    
  scenario "don't delete book as guest" do
    user = create(:user)
    create(:book, :user => user)
    
    visit books_path
    
    page.should_not have_content "Remover"
  end    
    
  scenario "tombo++" do
    user = create(:user)
    visit new_book_path
    fill_in "Título", :with => "Title 1"
    click_button "Salvar"
    user.books.last.tombo.should == 1
    
    visit new_book_path
    fill_in "Título", :with => "Title 2"
    click_button "Salvar"
    user.books.last.tombo.should == 2
  end
end

feature "Display Books", %q{
  In order to have an awesome library
  As guest
  I want to display books
} do
  
  scenario "RSS content" do
    create(:book, :title => "Primeiro")
    visit books_path(:rss)
      
    page.should have_content("Primeiro")
  end
  
  scenario "display books" do
    create(:book, :title => 'Title')
        
    visit books_path
  
    page.should have_content('Title')
  end
end


