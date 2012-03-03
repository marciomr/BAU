# coding: utf-8

require 'spec_helper'

feature "Create Books", %q{
  In order to have an awesome library
  As an admin
  I want to create and manage books
} do

  background do
    login
  end

  scenario "create a book with all atributes as admin", :js => true do
    visit new_book_path
    fill_in "isbn", :with => '7777777'
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
    
    page.should have_content('7777777')
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
  
  scenario "delete", :js => true do
    15.times{ Factory(:book) }
    
    visit books_path
    
    accept_js_confirm do
      within(:css, "li:first-child") do
        click_button "x"
      end    
    end
    
    page.should have_content "Livro deletado com sucesso"
    Book.count.should == 14
  end
    
  scenario "edit" do
    visit edit_book_path(Factory(:book, :title => "Lorem Ipsum"))
    fill_in "Título", :with => "A Conquista do Pão"
      
    click_button "Salvar"
    page.should have_content("Livro editado com sucesso")
    page.should have_content("A Conquista do Pão")
  end  
  
  scenario "see edit link" do
    book = Factory(:book, :title => "Lorem Ipsum")
    
    visit books_path
    
    page.should have_content "Editar"
    
    click_link "Editar"
    current_path.should == edit_book_path(book)
  end  
    
  scenario "delete without javascript" do
    15.times{ Factory(:book) }
    
    visit books_path
    
    within(:css, "li:first-child") do
      click_button "Remover"
    end    
    
    page.should have_content "Livro deletado com sucesso"
    Book.count.should == 14
  end  
    
  scenario "tombo + 1" do
    visit new_book_path
    fill_in "Título", :with => "Title 1"
    click_button "Salvar"
    Book.last.tombo.should == 1
    
    visit new_book_path
    fill_in "Título", :with => "Title 2"
    click_button "Salvar"
    Book.last.tombo.should == 2
  end
    
  scenario "add tag", :js => true do
    visit new_book_path
    fill_in "Título", :with => 'Title'
    click_link 'Add Tag'
    within(:css, "#tag .fields:first-child") do
      fill_in "Palavra Chave", :with => 'Anarquismo'
    end      
      click_link 'Add Tag'    
    within(:css, "#tag .fields:nth-child(2)") do
      fill_in "Palavra Chave", :with => 'Pedagogia'
    end
    click_button "Salvar"
    
    Book.last.tags.count.should == 2
    page.should have_content 'Anarquismo'
    page.should have_content 'Pedagogia'
  end 
    
  scenario "add author", :js => true do
    visit new_book_path
    fill_in "Título", :with => 'Title'
    within(:css, "#author .fields:first-child") do
      fill_in "Autor", :with => 'Kropotkin'
    end      
    click_link 'Add Author'
    within(:css, "#author .fields:nth-child(2)") do
      fill_in "Autor", :with => 'Proudon'
    end
    click_button "Salvar"
    
    Book.last.authors.count.should == 2
    page.should have_content 'Kropotkin'
    page.should have_content 'Proudon'
  end
  
end

feature "Display Books", %q{
  In order to have an awesome library
  As guest
  I want to display books
} do
  
  scenario "RSS content" do
    Factory(:book, :title => "Primeiro")
    visit books_path(:rss)
      
    page.should have_content("Primeiro")
  end
  
  scenario "display books" do
    Factory(:book, :title => 'Title')
        
    visit books_path
  
    page.should have_content('Title')
  end
end


