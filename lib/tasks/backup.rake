# coding: utf-8

require "#{Rails.root}/app/helpers/books_helper.rb"
include BooksHelper

namespace :backup do

desc "Save the current version of the RSS file in backups directory"
  task :save => :environment do
    require 'fileutils'
    require 'open-uri'
        
    rss = open("#{APP_CONFIG['url']}/books.rss")
    ts =  Time.now.utc.iso8601.gsub('-', '').gsub(':', '')
    filepath = "#{APP_CONFIG['backup_path']}/#{ts}.rss"
    file = File.open(filepath, "w")
    file.syswrite(rss.read)
    file.close
    
    last_backup_file = datetime_to_path(backup_files[-2])
    if File.identical?(filepath, last_backup_file)
      File.remove last_backup_file
      puts "Removendo #{last_backup_file} pois é identico ao novo" 
    end
    
    puts "Salvo em #{filepath}"
  end
  
  desc "Reset the whole database"
  task :reset do
    Rake::Task["db:reset"].invoke
  end

  desc "Recover the database from a certain date"    
  task :rebuild, [:ts] => [:reset, :environment] do |t, args|
    rebuild args.ts
  end
  
  desc "Recover the last database"
  task :rollback => [:reset, :environment] do
    rebuild Time.now.to_s
  end

  desc "Show a specific backup"
  task :show, [:ts] => :environment do |t, args|
    show args.ts
  end
  
  desc "Show the last backup"
  task :show_last => :environment do
    show Time.now.to_s
  end
    
  def show(datetime)
    require 'nokogiri'
    
    file = File.open(last_backup(datetime), "r")
    xml = Nokogiri::XML(file)
    file.close
    file = File.open(last_backup(datetime), "r")
    puts file.read 
    file.close
    
    ts = last_backup(datetime).split('/').last[/[0-9T]+/]

    puts "#{xml.css("item").count} itens"
    puts "#{ts[6..7]}/#{ts[4..5]}/#{ts[0..3]} - #{ts[9..10]}:#{ts[11..12]}:#{ts[12..13]}" 
    
  end  
    
  def rebuild(datetime)
    require 'nokogiri'

    file = File.open(last_backup(datetime), "r")       
    xml = Nokogiri::XML(file)
    
    xml.css("item").each_with_index do |item, i|
      params = {}

      (Book.simple_fields - ['subtitle', 'language']).each do |field|
        rss_name = rss_type(field) ? "#{rss_type(field)}|#{to_rss(field)}" : to_rss(field)
        unless item.at_css(rss_name).blank?
          params[field] = if ['year', 'page_number', 'tombo', 'volume'].include?(field)
            number = item.at_css(rss_name).text.to_i
            (number == 0 ? nil : number)
          elsif field == 'isbn'
            item.at_css(rss_name).text[/[0-9]+.*/] #idem
          else 
            item.at_css(rss_name).text 
          end 
        end
      end

      if item.css("dc|title").first != item.css("dc|title").last
        params['subtitle'] = item.css("dc|title").last.text 
      end      

      params["language"] = item.at_css("language").text unless  item.at_css("language").blank?
      params['created_at'] = DateTime.parse(item.at_css("pubDate").text)

      book = Book.new(params)      
      
      book.authors = item.css("dc|creator").collect{ |a| Author.new(:name => a.text) }
      book.tags = item.css("category").collect{ |t| Tag.new(:title => t.text) }
      
      book.save
    
      puts "Created #{i+1} of #{xml.css("item").count} books"
    end
    
    file.close
    
#    Rake::Task["thinking_sphinx:reindex"].invoke
    Rake::Task["thinking_sphinx:restart"].invoke
  end

  def backup_files
    files = Array.new
    
    Dir.entries(APP_CONFIG['backup_path']).each do |file|
      files.push DateTime.parse(file[/^\w+/]) unless file[/^\w+/].nil?
    end
    
    files.sort
  end
  
  def datetime_to_path(datetime)
    "#{APP_CONFIG['backup_path']}/#{datetime.to_s.gsub('-', '').gsub(':', '').gsub('+0000','Z')}.rss"
  end
  
  def last_backup(datetime)
    resposta = backup_files.first
    
    # arquivos do mais recente pro mais antigo    
    backup_files.reverse_each do |file|
      if DateTime.parse(datetime) > file
        resposta = file
        break
      end
    end

    datetime_to_path(resposta)
  end
  
  desc "Compare two versions of a file"
  task :compare do
    require 'ftools'
   
    return 0 if backup_files.size = 0
      
    file1 = "#{APP_CONFIG['backup_path']}/#{backup_files[-1].to_s.gsub('-', '').gsub(':', '').gsub('+0000','Z')}.rss"
    file2 = "#{APP_CONFIG['backup_path']}/#{backup_files[-2].to_s.gsub('-', '').gsub(':', '').gsub('+0000','Z')}.rss"
    puts File.compare(file1, file2) ? "Identicos" : "Nop"
  end
end
