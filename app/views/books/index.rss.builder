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
          xml.link book_url(book)
          xml.guid book_url(book)
          xml.language book.language
        
          book.tags.each do |tag|
            xml.category tag.title
          end
        
          # informacoes dublic core
          xml.tag!("dc:title", book.title)
          xml.tag!("dc:title", book.subtitle) if !book.subtitle.blank?
          xml.tag!("dc:date", book.year) if book.year && book.year != 0
          xml.tag!("dc:description", book.description) if !book.description.blank?
          xml.tag!("dc:publisher", book.editor) if !book.editor.blank?
          xml.tag!("dc:format", "#{book.page_number} pages") if book.page_number && book.page_number != 0 
          xml.tag!("dc:subject", book.subject) if !book.subject.blank?
          xml.tag!("dc:identifier", "ISBN:#{book.isbn}") if !book.isbn.blank?
          
          book.authors.each do |author|
            xml.tag!("dc:creator", author.name)
          end
          
          #informacoes extras para a biblioteca
          xml.tag!("tl:tombo", book.tombo)
          xml.tag!("tl:cidade", book.city) if !book.city.blank?
          xml.tag!("tl:pais", book.country) if !book.country.blank?
          xml.tag!("tl:acervo", book.collection) if !book.collection.blank?
          xml.tag!("tl:img", book.imglink) if !book.imglink.blank?
          xml.tag!("tl:pdf", book.pdflink) if !book.pdflink.blank?
          xml.tag!("tl:cdd", book.cdd) if !book.cdd.blank?
        	xml.tag!("tl:volume", book.volume) if book.volume && book.volume != 0
        end
      end
    end
  end
end
