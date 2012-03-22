# coding: utf-8
require 'open-uri'
class Book < ActiveRecord::Base
  extend FriendlyId
  friendly_id :tombo
  
  attr_accessible :user_id
  
  belongs_to :user
  validates_presence_of :user_id
  validates_uniqueness_of :tombo, :scope => :user_id
  validates_presence_of :title, :message => "O livro precisa ter um título."
  validates_format_of :pdflink, :imglink, :allow_blank => true, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :message => "Link inválido."
  # talvez eu devesse verificar se o link é válido - http://joshuawood.net/validating-url-in-ruby-on-rails-3/
  validates_numericality_of :year, :page_number, :volume, :only_integer => true, :allow_blank => true, :message => "Preencha com um número."

  before_save do |book| 
    t = book.user.last_tombo + 1
    book.tombo ||= t.to_s if book.tombo.nil?
  end

  def self.dc_fields
    ['isbn', 'title', 'subtitle', 'year', 'page_number', 'description', 'editor', 'subject', 'language']
  end

  def self.tl_fields
    ['tombo', 'volume', 'city', 'country', 'pdflink', 'imglink', 'cdd']
  end

  def self.complex_fields
    {'tags' => 'title', 'authors' => 'name'}
  end

  def self.simple_fields
    Book.tl_fields + Book.dc_fields + ['created_at']
  end
  
  def self.fields
    Book.simple_fields + Book.complex_fields.keys
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
    
    [:editor, :subtitle, :description, :subject, :pdflink, :language].each do |field|
      indexes field
    end

    indexes tags.title, :as => :tag
    indexes authors.name, :as => :author
    
    has user_id
    
    set_property :enable_star => true
    set_property :min_infix_len => 3
    
    set_property :delta => true
  end

  %w(author title editor language collection).each do |field|
    sphinx_scope("by_#{field}".to_sym) do | f |
      {:conditions => { field.to_sym => f }}
    end
  end

  sphinx_scope(:order_by_relevance_title) do
    {:sort_mode => :extended, :order => "title ASC, @relevance DESC"}
  end

  sphinx_scope(:with_pdflink) do
    {:conditions => { :pdflink => 'http'}}
  end

  sphinx_scope(:with_user_id) do |f|
    {:with => { :user_id => f }}
  end

  # get the authors names and tags titles joined with ,  
  Book.complex_fields.each do |k, v| 
    define_method "#{k}_#{v}s" do
      send(k).map{ |a| a.send(v) }.join(', ')
    end
  end
  
  # get the fields concatenated with ,
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
  
  def self.get_attributes_from_gbook(isbn)
    uri = "http://books.google.com/books/feeds/volumes?q=isbn:#{isbn}"
    xml = Nokogiri::XML(open(uri))
    entry = xml.at_css("entry") 
    
    return nil if entry.nil?
      
    attributes = {}
   
    attributes['isbn'] = isbn   
   
    return attributes if entry.nil?
     
    (Book.dc_fields - ['isbn', 'subtitle']).each do |field|
      unless entry.at_css("dc|#{Book.to_rss(field)}").nil?
        rss_field = entry.at_css("dc|#{Book.to_rss(field)}").text
        if rss_field
          attributes[field] = case field
            when 'year' then rss_field[/[0-9]{4}/]
            when 'page_number' then rss_field[/[0-9]+/]
            when 'description' then rss_field.gsub(/\n/,"")
            else rss_field.titleize 
          end
        end
      end
    end
    
    if entry.css('dc|title').size > 1 #the second dc:title is the subtitle
      attributes['subtitle'] = entry.css('dc|title').last.text.titleize
    end    
    
    attributes['authors_attributes'] = {}
    entry.css("dc|creator").each_with_index do |author, i|
      attributes['authors_attributes'][i.to_s] = { 'name' => author.text.titleize }
    end
    
    attributes
  end
  
  def self.get_attributes_from_library(isbn)
    book = Book.find_by_isbn(isbn)
    if book
      attributes = book.attributes
      attributes['authors_attributes'] = {}
      Author.find_all_by_book_id(book.id).each_with_index do |author, i|
        attributes['authors_attributes'][i.to_s] = { 'name' => author.name.titleize }
      end
    end
    attributes
  end
  
  def self.get_attributes(isbn)
    Book.get_attributes_from_library(isbn) || Book.get_attributes_from_gbook(isbn)
  end
    
  
end
