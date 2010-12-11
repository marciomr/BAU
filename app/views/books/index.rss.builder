xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", 'xmlns:dc' => 'http://purl.org/dc/terms', 'xmlns:tl' => 'http://www.terralivre.com/terms' do
  xml.channel do
    xml.title "Terra Livre"
    xml.description "Catálogo de livros da Biblioteca Terra Livre"
    xml.link books_url(:format => :rss)

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
        xml.tag!("dc:title", book.subtitle) if book.subtitle && !book.subtitle.empty?
        xml.tag!("dc:date", book.year) if book.year
        xml.tag!("dc:description", book.description) if book.description && !book.description.empty?
        xml.tag!("dc:publisher", book.editor) if book.editor && !book.editor.empty?
        xml.tag!("dc:format", "#{book.page_number} pages") if book.page_number
        xml.tag!("dc:subject", book.subject) if book.subject && !book.subject.empty?
        
        book.authors.each do |author|
          xml.tag!("dc:creator", author.name)
        end
        
        #informacoes extras para a biblioteca
        xml.tag!("tl:tombo", book.tombo)
        xml.tag!("tl:cidade", book.city) if book.city && !book.city.empty?
        xml.tag!("tl:pais", book.country) if book.country && !book.country.empty?
        xml.tag!("tl:acervo", book.collection) if book.collection && !book.collection.empty?
        xml.tag!("tl:img", book.imglink) if book.imglink && ! book.imglink.empty?
        xml.tag!("tl:pdf", book.pdflink) if book.pdflink && !book.pdflink.empty?
        xml.tag!("tl:cdd", book.cdd) if book.cdd && !book.cdd.empty?
      	xml.tag!("tl:volume", book.volume) if book.volume
      end
    end
  end
end
