class Book < ActiveRecord::Base
  has_many :authors, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  #accepts_nested_attributes_for :authors
  
  # não aceita livros sem título
  validates_presence_of :title
  
  # verifica se o link para a imagem e para o pdf são urls válidos
  validates_format_of :imglink, :pdflink, :with =>
        /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
           
  attr_accessible :title, :editor, :city, :country, :year, :language, :description 
  attr_accessible :collection, :cdd, :author_attributes, :tag_attributes, :pdflink, :imglink
  attr_accessible :subject, :page_number, :tombo, :volume, :subtitle, :isbn

  after_update :save_authors, :save_tags

  define_index do
    indexes title
    indexes subtitle
    indexes description
    indexes subject
    indexes tags.title, :as => :tag
    indexes authors.name, :as => :author
    
    set_property :enable_star => true
    set_property :min_infix_len => 3
    
    set_property :delta => true
  end

  def self.last_tombo
    all.map{ |b| b.tombo }.sort.last || 0
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

 def tag_attributes=(tag_attributes)
    tag_attributes.each do |attributes|
      if attributes[:id].blank?
        tags.build(attributes)
      else
        tag = tags.detect {|t| t.id == attributes[:id].to_i}
        tag.attributes = attributes
      end
    end
  end

  def save_tags
    tags.each do |t|
      if t.should_destroy?
        t.destroy
      else
        t.save(false)
      end
    end
  end

  def tag_titles
    tags.map{ |t| t.title }.join(', ')
  end
  
end
