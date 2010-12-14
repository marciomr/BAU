class AddVolumeToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :volume, :integer
  end

  def self.down
    remove_column :books, :volume
  end
end
