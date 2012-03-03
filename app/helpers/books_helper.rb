module BooksHelper
  
  def rss_type(field)
    return 'dc' if Book.dc_fields.include? field
    return 'tl' if Book.tl_fields.include? field
  end
  
  def to_rss(field)
    Book.to_rss(field)
  end
  
  def index_label(book)
    book.title + (book.volume ? " - Vol. #{(book.volume).to_roman}" : "")
  end
  
end
