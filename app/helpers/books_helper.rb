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
  
  def adv_search_create(name)
    link_to_function name, :id => :adv_search_link do |page|
      page[:adv_search_link].hide
      page.insert_html :bottom, :search_form, :partial => 'adv_search'
      page[:advanced_search].visual_effect :slide_down, :duration => 0.3
    end
  end
  
  def adv_search_destroy(name)
    link_to_function name, :id => :adv_search_link do |page|
      page[:advanced_search].visual_effect :slide_up, :duration => 0.3
      page.delay(0.3) do 
        page[:advanced_search].remove
        page[:adv_search_link].show
      end
    end
  end
end
