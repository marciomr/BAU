xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", 'xmlns:dc' => 'http://purl.org/dc/terms', 'xmlns:tl' => 'http://www.terralivre.com/terms' do
  xml.channel do
    xml.title "Terra Livre"
    xml.description "Catálogo de livros da Biblioteca Terra Livre"
    xml.link books_url(:format => :rss)
    
    if @books 
      for book in @books
        xml.item do
          authors_names = book.authors.map{ |a| a.name }.join(', ')
        
          # informacoes para o RSS
          xml.title book.title
          xml.description "<h3>#{authors_names}</h3> #{book.description}"
          xml.pubDate book.created_at.to_s(:rfc822)
          xml.link user_book_url(book.user, book)
          xml.guid user_book_url(book.user, book)
          xml.language book.language
        
          book.tags.each do |tag|
            xml.category tag.title
          end
        
          (Book.dc_fields + Book.tl_fields).each do |field|
            value = book.send field
            if (value.class == String && !value.blank? ||
                value.class == Fixnum && value && value != 0)
                case field
                when 'page_number'
                  value = "#{value} pages"
                when 'isbn'
                  value = "ISBN:#{value}"
                end
                xml.tag!("#{rss_type(field)}:#{field}", value) 
            end
          end

          book.authors.each do |author|
            xml.tag!("dc:creator", author.name)
          end
          
        end
      end
    end
  end
end
