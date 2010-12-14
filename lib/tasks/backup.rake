namespace :backup do

  URL = "http://bibliotecaterralivre.sarava.org/books.rss"
  
  desc "Save the current version of the RSS file in backups directory"
  task :save => :environment do
    require 'ftools'
    require 'open-uri'
    
    rss = open(URL)
    ts =  Time.now.utc.iso8601.gsub('-', '').gsub(':', '')
    filepath = "#{APP_CONFIG['backup_path']}/#{ts}.rss"
    file = File.open(filepath, "w")
    file.syswrite(rss.read)
    file.close
    
    last_backup_file = datetime_to_path(backup_files[-2])
    if File.compare(filepath, last_backup_file)
      File.delete last_backup_file
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
    
  def rebuild(datetime)
    require 'nokogiri'

    file = File.open(last_backup(datetime), "r")       
    xml = Nokogiri::XML(file)
    
    xml.css("item").each_with_index do |item, i|
      authors = Array.new
      
      item.css("dc|creator").each do |author|
        authors.push(Author.find_or_create_by_name(author.text))
      end
      
      tags = Array.new
      
      item.css("category").each do |tag|
        tags.push(Tag.find_or_create_by_title(tag.text))
      end
      
      title = item.css("dc|title").first.text	
      subtitle = item.css("dc|title").last.text if item.css("dc|title").first != item.css("dc|title").last
      year = item.at_css("dc|date").text.to_i unless item.at_css("dc|date").nil? 
      editor = item.at_css("dc|publisher").text unless item.at_css("dc|publisher").nil?
      description = item.at_css("dc|description").text unless item.at_css("dc|description").nil?
      pages = item.at_css("dc|format").text.to_i unless item.at_css("dc|format").nil?
      subject = item.at_css("dc|subject").text unless item.at_css("dc|subject").nil?
      
      tombo = item.at_css("tl|tombo").text
      volume = item.at_css("tl|volume").text.to_i unless item.at_css("tl|volume").nil?
      city = item.at_css("tl|cidade").text unless item.at_css("tl|cidade").nil?
      country = item.at_css("tl|pais").text unless item.at_css("tl|pais").nil?
      collection = item.at_css("tl|acervo").text unless item.at_css("tl|acervo").nil?
      pdflink = item.at_css("tl|pdf").text unless item.at_css("tl|pdf").nil?
      imglink = item.at_css("tl|img").text unless item.at_css("tl|img").nil?
      isbn = item.at_css("dc|identifier").text[/[0-9]+.*/] unless item.at_css("dc|identifier").nil?   
      
      created_at = DateTime.parse(item.at_css("pubDate").text)
      language = item.at_css("language").text unless item.at_css("language").nil?
      
      book = Book.new(
        :isbn => isbn,
        :tombo => tombo,
        :created_at => created_at,
        :title => title,
	      :subtitle => subtitle,
	      :volume => volume,
        :year => year,
        :editor => editor,
        :description => description,
        :pages => pages,
        :subject => subject,
        :city => city,
        :country => country,
        :collection => collection,
        :pdflink => pdflink,
        :imglink => imglink
      )
      
      book.authors = authors
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
  
  task :compare do
    require 'ftools'
    
    file1 = "#{APP_CONFIG['backup_path']}/#{backup_files[-1].to_s.gsub('-', '').gsub(':', '').gsub('+0000','Z')}.rss"
    file2 = "#{APP_CONFIG['backup_path']}/#{backup_files[-2].to_s.gsub('-', '').gsub(':', '').gsub('+0000','Z')}.rss"
    puts File.compare(file1, file2) ? "Identicos" : "Nop"
  end
end
