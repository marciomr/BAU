class Book < ActiveRecord::Base
  has_many :authors, :dependent => :destroy
  #accepts_nested_attributes_for :authors
           
  attr_accessible :title, :editor, :city, :country, :year, :language, :description 
  attr_accessible :collection, :cdd, :author_attributes

  after_update :save_authors

  define_index do
    indexes title
    indexes description
    indexes authors.name, :as => :author
    
    set_property :delta => true
  end

  def author_attributes=(author_attributes)
    author_attributes.each do |attributes|
      if attributes[:id].blank?
        authors.build(attributes)
      else
        author = authors.detect {|t| t.id == attributes[:id].to_i}
        author.attributes = attributes
      end
    end
  end

  def save_authors
    authors.each do |a|
      if a.should_destroy?
        a.destroy
      else
        a.save(false)
      end
    end
  end
  
  def authors_names
    authors.map{ |a| a.name }.join(', ')
  end

end
