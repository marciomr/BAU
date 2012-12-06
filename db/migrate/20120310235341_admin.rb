class Admin < ActiveRecord::Migration
  def up
    User.create(:id => 1, :username => "admin", :name => "Admin", :password => "secret")
  end

  def down
    User.delete(User.find(1))
  end
end
