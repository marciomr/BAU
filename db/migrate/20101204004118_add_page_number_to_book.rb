class AddPageNumberToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :page_number, :integer
  end

  def self.down
    remove_column :books, :page_number
  end
end
