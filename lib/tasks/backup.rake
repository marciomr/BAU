# coding: utf-8

namespace :backup do

def view(url_options = {}, *view_args)
  view_args[0] ||= ActionController::Base.view_paths
  view_args[1] ||= {}
  
  view = ActionView::Base.new(*view_args)
  routes = Rails::Application.routes
  routes.default_url_options = {:host => 'localhost'}.merge(url_options)

  view.class_eval do
    include ApplicationHelper
    include routes.url_helpers
  end

  assigns = instance_variables.inject(Hash.new) do |hash, name|
    hash.merge name[1..-1] => instance_variable_get(name)
  end
  view.assign assigns
  
  view
end

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

      dc = ['date', 'format', 'publisher', 'description', 'publisher', 'subject', 'title']
      tl = ['tombo', 'volume', 'cidade', 'pais', 'acervo', 'pdf', 'img']
      
      fields_number = ['date', 'format', 'tombo', 'volume']
      fields_string = ['publisher', 'description', 'subject', 'cidade', 'pais']
      fields_string += ['acervo', 'pdf', 'img', 'title']
      
      fields_number.each do |field|
        type = (dc.include?(field) ? 'dc' : 'tl')
        unless item.at_css("#{type}|#{field}").blank?
          number = item.at_css("#{type}|#{field}").text.to_i
          params[field.to_sym] = (number == 0 ? nil : number)
        end
      end
      
      fields_string.each do |field| 
        type = (dc.include?(field) ? 'dc' : 'tl')
        unless item.at_css("#{type}|#{field}").blank?
          params[field.to_sym] = item.at_css("#{type}|#{field}").text
        end
      end
      
      if item.css("dc|title").first != item.css("dc|title").last
        params[:subtitle] = item.css("dc|title").last.text 
      end      
      params[:created_at] = DateTime.parse(item.at_css("pubDate").text)
      params[:language] = item.at_css("language").text unless item.at_css("language").nil?
      unless item.at_css("dc|identifier").nil?
        params[:isbn] =  item.at_css("dc|identifier").text[/[0-9]+.*/] 
      end
      
      book = Book.new(
        :isbn => params[:isbn],
        :tombo => params[:tombo],
        :created_at => params[:created_at],
        :title => params[:title],
	      :subtitle => params[:subtitle],
	      :volume => params[:volume],
        :year => params[:date],
        :editor => params[:publisher],
        :description => params[:description],
        :page_number => params[:format],
        :subject => params[:subject],
        :city => params[:cidade],
        :country => params[:pais],
        :collection => params[:acervo],
        :language => params[:language],
        :pdflink => params[:pdf],
        :imglink => params[:img]
      )
      
      authors = []
      item.css("dc|creator").each do |author|
        authors.push(Author.new(:name => author.text))
      end
      book.authors = authors
      
      tags = Array.new
      item.css("category").each do |tag|
        tags.push(Tag.new(:name => tag.text))
      end
      book.tags = tags
      
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
