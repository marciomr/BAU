class AddSubjectToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :subject, :string
  end

  def self.down
    remove_column :books, :subject
  end
end
