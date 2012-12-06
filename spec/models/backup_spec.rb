# coding: utf-8

require 'spec_helper'

describe Backup do
  
  it 'should return all files sorted by date' do
    files = "#{Backup.folder('foo_bar_1')}/20120408T1844550300.xml", "#{Backup.folder('foo_bar_2')}/20120408T1844540300.xml"
    Dir.stubs(:[]).with("#{Backup.folder}/**/*.xml").returns([files[0], files[1]])

    Backup.all.each_with_index do |backup, i|
      backup.date.should ==  Time.new(2012, 4, 8, 18, 44, 55 - i)
      backup.username.should == "foo_bar_#{i + 1}"
      backup.path == files[i]
    end
  end
  
  it 'should return files of a user' do
    files = "#{Backup.folder('foo_bar_1')}/20120408T1844550300.xml", "#{Backup.folder('foo_bar_2')}/20120408T1844540300.xml"
    Dir.stubs(:[]).with("#{Backup.folder}/**/*.xml").returns([files[0], files[1]])

    backups = Backup.find_by_username('foo_bar_1')

    backups.count.should == 1
    
    backup = backups.first
      
    backup.date.should ==  Time.new(2012, 4, 8, 18, 44, 55)
    backup.username.should == "foo_bar_1"
    backup.path == files[0]
  end
  
end
