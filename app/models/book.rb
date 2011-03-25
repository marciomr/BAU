class Book < ActiveRecord::Base
  attr_accessible :title, :editor, :city, :country, :year, :language
  attr_accessible :description, :collection, :cdd, :subtitle, :page_number
  attr_accessible :volume, :isbn, :subject, :pdflink, :imglink, :authors_attributes 
  attr_accessible :tags_attributes, :tombo, :created_at

  has_many :tags, :dependent => :destroy
  has_many :authors, :dependent => :destroy
  accepts_nested_attributes_for :tags, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true  
  accepts_nested_attributes_for :authors, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true  

  define_index do
    indexes title, :sortable => true
    indexes subtitle
    indexes description
    indexes subject
    indexes tags.title, :as => :tag
    indexes authors.name, :as => :author
    
    indexes pdflink
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
  
  sphinx_scope(:order_by_relevance_title) do
    {:sort_mode => :extended, :order => "title ASC, @relevance DESC"}
  end

  sphinx_scope(:with_pdflink) do
    {:conditions => { :pdflink => "http" }}
  end

  def self.last_tombo
    self.count == 0 ? 0 : all.map{ |b| b.tombo }.sort.last
  end

  def authors_names
    authors.map{ |a| a.name }.join(', ')
  end

  def tag_titles
    tags.map{ |t| t.title }.join(', ')
  end
  
  def self.collections
    all.map{ |b| b.collection }.uniq.delete_if{ |x| x.blank? }.unshift("")
  end
  
  def self.languages
    all.map{ |b| b.language }.uniq.delete_if{|x| x.blank? }.unshift("")
  end
  
  def self.gbook(isbn)
    uri = "http://books.google.com/books/feeds/volumes?q=isbn:#{isbn}"
    xml = Nokogiri::XML(open(uri))
    entry = xml.at_css("entry") 
    params = {}
   
    params[:isbn] = isbn   
   
    return params if entry.nil?
     
    ['title', 'subject', 'language', 'date', 'publisher', 'format'].each do |token|
      unless entry.at_css("dc|#{token}").nil?
        params[token.to_sym] = entry.at_css("dc|#{token}").text
      end
    end
    
    if entry.css('dc|title').size > 1 #the second dc:title is the subtitle
      params[:subtitle] = entry.css('dc|title').last.text.titleize
    end    
    
    params[:authors] = []
    entry.css("dc|creator").each do |author|
      params[:authors] << author.text.titleize 
    end
    
    [:title, :subtitle, :subject, :publisher].each do |token|
      params[token] = params[token].titleize if params[token]
    end
    
    params[:date] = params[:date][/[0-9]{4}/] if params[:date]
    params[:format] = params[:format][/[0-9]+/] if params[:format]

    params
  end
end
