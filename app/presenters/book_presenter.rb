  # coding: utf-8
class BookPresenter < BasePresenter
  presents :book
  
  def authors
    complex_field(:authors, :name, 'Autor', 'Autores')
  end
  
  def tags
    complex_field(:tags, :title, 'Palavra Chave', 'Palavras Chaves')
  end
  
  def book_link(book)
    options = {:class => 'book-title', :rel => 'tooltip', :title => book.title_volume}
    if params[:user_id]
      link_to truncated_title(book, 60), user_books_path(@user, params.merge(:book => book.tombo)), options
    else
      link_to truncated_title(book, 50), params.merge(:book => book.tombo, :user => book.user.username), options 
    end
  end
  
  def authors_with_tooltip(book)
    truncate_with_tooltip(book.authors.map(&:name).to_sentence(:two_words_connector => ' e ', 
                                                               :last_word_connector => ' e '), '#', :class => 'authors')
  end
  
  private

  def truncated_title(book, length)
    "#{truncate(book.title, :length => length)} #{book.volume}"
  end
  
  def search_path(filter_name, obj)
    if params[:user_id]
      user_books_path(@user, "#{filter_name}_filter".to_sym => obj)
    else
      {"#{filter_name}_filter".to_sym => obj}
    end
  end
  
  def complex_field(model_name, field, singular, plural)
    if !book.send(model_name).empty?
      content_tag :p do
        content = content_tag :strong do
          pluralize(model_name, singular, plural) + ': ' 
        end
        content << book.send(model_name).map do |m| 
          link_to m.send(field), search_path(model_name.to_s.singularize, m.send(field))
        end.to_sentence(:two_words_connector => ' e ', :last_word_connector => ' e ').html_safe
      end
    end
  end
  
end
