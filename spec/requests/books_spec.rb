# coding: utf-8

require 'spec_helper'

feature "Create Books", %q{
  In order to have an awesome library
  As an admin
  I want to create and manage books even with js off
} do

  background do
    login
  end

# ATENCAO SEM JS NAUM CONSIGO SALVAR O ISBN

 scenario "create a book with all atributes as admin" do
    visit new_book_path
    fill_in "Título", :with => "A Conquista do Pão"
    fill_in "Subtítulo", :with => "como conquistar o pão"
    fill_in "Volume", :with => "222"
    fill_in "Autor", :with => "Foo Bar"
    fill_in "Editor", :with => "Imaginarium"
    fill_in "Ano", :with => "2011"
    fill_in "Língua", :with => "pt"
    fill_in "Número de Páginas", :with => "200"
    fill_in "Assunto", :with => "Anarquismo"
    fill_in "Acervo", :with => "Ay"
    fill_in "Cidade", :with => "São Paulo"
    fill_in "País", :with => "Brasil"
    fill_in "CDD", :with => "234DFG23"
    fill_in "Imagem", :with => "http://bibliotecaterralivre.org"
    fill_in "PDF", :with => "http://www.example.com"  
    fill_in "Descrição", :with => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
   
    click_button "Salvar"
        
    Book.should have(1).record
    
    page.should have_content("Livro criado com sucesso.")
    
    page.should have_content("A Conquista do Pão") 
    page.should have_content("como conquistar o pão") 
    page.should have_content("222")
    page.should have_content("Foo Bar") 
    page.should have_content("Imaginarium") 
    page.should have_content("2011") 
    page.should have_content("pt") 
    page.should have_content("200") 
    page.should have_content("Anarquismo") 
    page.should have_content("Ay")
    page.should have_content("São Paulo") 
    page.should have_content("Brasil") 
    page.should have_content("234DFG23") 
    page.should have_content("Lorem ipsum") 
    page.should have_css('a[href^="http://www.example.com"]')
    page.should have_css('img[src^="http://bibliotecaterralivre.org"]')
  end
  
  scenario "edit" do
    author = create(:author, :name => "Kropotkin")
    book = create(:book, :title => "Lorem Ipsum", :authors => [author])
    visit edit_book_path(book)
    
    find(:field, 'book_title').value.should have_content(book.title)
    find(:css, '.book_author').value.should have_content(author.name)
    
    fill_in "Título", :with => "A Conquista do Pão"
      
    click_button "Salvar"
    page.should have_content("Livro editado com sucesso")
    page.should have_content("A Conquista do Pão")
  end  
  
  scenario "see edit link" do
    book = create(:book, :title => "Lorem Ipsum")
    
    visit books_path
    
    page.should have_content "Editar"
    
    click_link "Editar"
    current_path.should == edit_book_path(book)
  end  
    
  scenario "delete" do
    15.times{ create(:book) }
    
    visit books_path
    
    within(:css, "li:first-child") do
      click_button "Remover"
    end    
    
    page.should have_content "Livro deletado com sucesso"
    Book.should have(14).record
  end  
    
  scenario "tombo++" do
    visit new_book_path
    fill_in "Título", :with => "Title 1"
    click_button "Salvar"
    Book.last.tombo.should == 1
    
    visit new_book_path
    fill_in "Título", :with => "Title 2"
    click_button "Salvar"
    Book.last.tombo.should == 2
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


