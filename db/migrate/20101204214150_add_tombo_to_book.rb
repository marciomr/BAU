class AddTomboToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :tombo, :integer
  end

  def self.down
    remove_column :books, :tombo
  end
end
