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
    indexes title, :sortable => true
    indexes subtitle
    indexes description
    indexes subject
    indexes tags.title, :as => :tag
    indexes authors.name, :as => :author
    
    indexes collection
    indexes language
    
    set_property :enable_star => true
    set_property :min_infix_len => 3
    
    set_property :delta => true
  end

  sphinx_scope(:by_author) do | author |
    {:conditions => { :author => author }}
  end
  
  sphinx_scope(:by_title) do | title |
    {:conditions => { :title => title }}
  end
  
  sphinx_scope(:by_editor) do | editor |
    {:conditions => { :editor => editor }}
  end

  sphinx_scope(:by_language) do | language |
    {:conditions => { :language => language }}
  end
  
  sphinx_scope(:by_collection) do | collection |
    {:conditions => { :collection => collection }}
  end
  
  sphinx_scope(:paginate) do | per_page |
    {:page => per_page, :per_page => 20 }
  end
  
  sphinx_scope(:order_by_relevance_title) do
    {:sort_mode => :extended, :order => "title ASC, @relevance DESC"}
  end
  
  def self.collections
    all.map{ |b| b.collection }.uniq.delete_if{ |x| x.blank? }.unshift("")
  end

  def self.languages
    all.map{ |b| b.language }.uniq.delete_if{|x| x.blank? }.unshift("")
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
