class Session < ActiveRecord::Base

  def self.logon(pass)
    pass ==  "secret"
  end

end
