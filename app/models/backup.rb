class Backup
  attr_accessor :username, :file, :path, :date
  
  def self.all
    files = Dir["#{self.folder}/**/*.xml"].map do |path|
      new(path)
    end
    files.sort{ |x, y| y.date <=> x.date }
  end
  
  def self.find_by_username(username)
    all.select { |l| l.username == username }
  end    
  
  def initialize(path)
    tree = path.split('/').drop(1)
    @path = "/#{tree.join('/')}"
    @username, @file = tree.last(2)
    @date = Time.strptime(file.split('.')[0], "%Y%m%dT%H%M%S")
  end
  
  def self.new_file(username)
    ts =  Time.now.iso8601.gsub('-', '').gsub(':', '')
    File.new("#{self.folder(username)}/#{ts}.xml", "w")
  end
  
  private
  
  def self.folder(username = nil)
    folder = "#{Rails.root}/public/backups"
    folder += "/#{username}" if username
    folder
  end    
end
