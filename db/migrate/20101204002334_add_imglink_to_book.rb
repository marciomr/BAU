class AddImglinkToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :imglink, :string
  end

  def self.down
    remove_column :books, :imglink
  end
end
