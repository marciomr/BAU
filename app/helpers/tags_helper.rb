module TagsHelper
  def tag_titles
    tags.map{ |t| t.name }.join(', ')
  end
end
