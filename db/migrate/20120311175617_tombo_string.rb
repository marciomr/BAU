class TomboString < ActiveRecord::Migration
  def up
    remove_column :books, :tombo
    add_column :books, :tombo, :string
  end

  def down
    remove_column :books, :tombo
    add_column :books, :tombo, :integer
  end
end
