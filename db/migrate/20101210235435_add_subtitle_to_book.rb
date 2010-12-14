class AddSubtitleToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :subtitle, :string
  end

  def self.down
    remove_column :books, :subtitle
  end
end
