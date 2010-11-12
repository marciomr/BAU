class DeltaIndex < ActiveRecord::Migration
  def self.up
    add_column :books, :delta, :boolean, :default => true,
    :null => false
  end

  def self.down
    remove_column :books, :delta
  end
end
