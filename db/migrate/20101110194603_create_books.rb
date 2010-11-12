class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :title
      t.string :editor
      t.string :city
      t.string :country
      t.integer :year
      t.string :language
      t.text :description
      t.string :collection
      t.string :cdd
      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
