module BooksHelper

  def roman(num)
    return "" if num == 0
    return "I"*num if num < 4
    return "IV" if num == 4 
    return "V" + roman(num - 5) if num < 9
    return "IX" if num == 9
    return "X"*(num/10) + roman(num%10) if num < 40
    return "XL" + roman(num - 40) if num < 50
    return "L" + roman(num - 50) if num < 90
  end
  
  def rss_type(field)
    return 'dc' if Book.dc_fields.include? field
    return 'tl' if Book.tl_fields.include? field
  end
  
  def to_rss(field)
    Book.to_rss(field)
  end
  
  def index_label(book)
    book.title + (book.volume ? " - Vol. #{roman(book.volume)}" : "")
  end
  
end
