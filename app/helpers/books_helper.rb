module BooksHelper
  
  def add_author_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :authors, :partial => 'author', :object => Author.new
      author = page.select('.author').last
      author.visual_effect :slide_down, :duration => 0.3
    end
  end
  
  def add_tag_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :tags, :partial => 'tag', :object => Tag.new
      tag = page.select('.tag').last
      tag.visual_effect :slide_down, :duration => 0.3
    end
  end
  
end
