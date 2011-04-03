class Book < ActiveRecord::Base

  def self.dc_fields
    ['isbn', 'title', 'subtitle', 'year', 'page_number', 'description', 'editor', 'subject', 'language']
  end

  def self.tl_fields
    ['tombo', 'volume', 'city', 'country', 'collection', 'pdflink', 'imglink', 'cdd']
  end

  def self.complex_fields
    {'tags' => 'title', 'authors' => 'name'}
  end

  def self.fields
    Book.tl_fields + Book.dc_fields + ['created_at', 'tags', 'authors']
  end
  
  def self.simple_fields
    Book.fields - Book.complex_fields.keys
  end 

  Book.simple_fields.each do |field|
    attr_accessible field.to_sym
  end
  
  Book.complex_fields.keys.each do |field|
    attr_accessible "#{field}_attributes".to_sym
  end
  
  Book.complex_fields.each do |key, value|
    has_many key.to_sym, :dependent => :destroy
    accepts_nested_attributes_for key.to_sym, :reject_if => lambda{ |a| a[value.to_sym].blank? }, :allow_destroy => true
  end

  define_index do
    indexes title, :sortable => true
    
    [:subtitle, :description, :subject, :pdflink, :collection, :language].each do |field|
      indexes field
    end

    indexes tags.title, :as => :tag
    indexes authors.name, :as => :author
    
    set_property :enable_star => true
    set_property :min_infix_len => 3
    
    set_property :delta => true
  end

  ['author', 'title', 'editor', 'language', 'collection'].each do |field|
    sphinx_scope("by_#{field}".to_sym) do | f |
      {:conditions => { field.to_sym => f }}
    end
  end

  sphinx_scope(:order_by_relevance_title) do
    {:sort_mode => :extended, :order => "title ASC, @relevance DESC"}
  end

  sphinx_scope(:with_pdflink) do
    {:conditions => { :pdflink => "http" }}
  end

#  scope :no_duplication, lambda { where() }

  def self.last_tombo
    self.count == 0 ? 0 : all.map{ |b| b.tombo }.sort.last
  end

  Book.complex_fields.each do |k, v| 
    define_method "#{k}_#{v}s" do
      send(k).map{ |a| a.send(v) }.join(', ')
    end
  end
  
  Book.simple_fields.each do |field|
    self.class.class_eval do
      define_method "#{field}s" do
        all.map{ |b| b.send(field) }.uniq.delete_if{ |x| x.blank? }
      end
    end
  end
  
  def self.to_rss(field)
    hash = {'year' => 'date', 'editor' => 'publisher', 'page_number' => 'format', 
            'city' => 'cidade', 'country' => 'pais', 'collection' => 'acervo', 
            'pdflink' => 'pdf', 'imglink' => 'img', 'subtitle' => 'title', 
            'isbn' => 'identifier'}
    return hash[field] if hash.keys.include? field
    field
  end
  
  def self.gbook(isbn)
    uri = "http://books.google.com/books/feeds/volumes?q=isbn:#{isbn}"
    xml = Nokogiri::XML(open(uri))
    entry = xml.at_css("entry") 
    params = {}
   
    params['isbn'] = isbn   
   
    return params if entry.nil?
     
    (Book.dc_fields - ['isbn', 'subtitle']).each do |field|
      unless entry.at_css("dc|#{Book.to_rss(field)}").nil?
        rss_field = entry.at_css("dc|#{Book.to_rss(field)}").text
        if rss_field
          params[field] = case field
            when 'year' then rss_field[/[0-9]{4}/]
            when 'page_number' then rss_field[/[0-9]+/]
            when 'description' then rss_field.gsub(/\n/,"")
            else rss_field.titleize 
          end
        end
      end
    end
    
    if entry.css('dc|title').size > 1 #the second dc:title is the subtitle
      params['subtitle'] = entry.css('dc|title').last.text.titleize
    end    
    
    params['authors'] = entry.css("dc|creator").collect{ |a| a.text.titleize }
    
    params
  end
end
