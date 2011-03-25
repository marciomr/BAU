class AddNewFieldsToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :pdflink, :string
    add_column :books, :imglink, :string
    add_column :books, :subject, :string
    add_column :books, :page_number, :integer
    add_column :books, :tombo, :integer
    add_column :books, :volume, :integer
    add_column :books, :subtitle, :string
    add_column :books, :isbn, :string
  end

  def self.down
    remove_column :books, :pdflink
    remove_column :books, :imglink
    remove_column :books, :subject
    remove_column :books, :page_number
    remove_column :books, :tombo
    remove_column :books, :volume
    remove_column :books, :subtitle
    remove_column :books, :isbn
    remove_column :books, :pdflink
  end
end
