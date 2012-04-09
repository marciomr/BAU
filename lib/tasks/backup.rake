# coding: utf-8

require "#{Rails.root}/app/helpers/books_helper.rb"

namespace :backup do
  desc "Criar Backup"
  task :create => :environment do
    user = User.find_by_username(ENV['USERNAME'])
    
    file = Backup.new_file(ENV['USERNAME'])

    file.write(books_to_xml(user.books))
    file.close
    puts "[#{DateTime.now}] Backup criado com sucesso!"
  end
  
  desc "Recover Backup"
  task :recover => :environment do
    user = User.find_by_username(ENV['USERNAME'])
    
    file = File.new("#{Backup.folder(ENV['USERNAME'])}/#{ENV['ID']}.xml", "r")
    
    xml = Hash.from_xml(file)
    
    user.books.delete_all  
      
    xml['books'].each do | book |
      book['authors_attributes'] = book.delete('authors')
      book['tags_attributes'] = book.delete('tags')
      
      Book.new(book.merge(:user_id => user.id)).save  
    end
    puts "[#{DateTime.now}] Arquivo recuperado com sucesso!"
  end
  
  def books_to_xml(books)
    exceptions = %w(user_id id created_at updated_at delta)
    
    xml = Builder::XmlMarkup.new(:indent => 2)

    xml.instruct!(:xml, :encoding => "UTF-8")

    xml.books(:type => "array") do
      books.each do |b|
        xml.book do
          b.attributes.each do |k,v|
            if !exceptions.include? k
              if b.column_for_attribute(k).type == :integer
                xml.tag!(k, v, :type => 'integer')
              else
                xml.tag!(k, v)
              end
            end 
          end
          xml.authors(:type => "array") do
            b.authors.each do |a|
              xml.author{ xml.name a.name }
            end
          end  
          xml.tags(:type => "array") do
            b.tags.each do |t|
              xml.tag{ xml.title t.title }
            end
          end
        end
      end
    end
  end
  
end


