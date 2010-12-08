class AddPdflinkToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :pdflink, :string
  end

  def self.down
    remove_column :books, :pdflink
  end
end
