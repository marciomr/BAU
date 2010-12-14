class Session < ActiveRecord::Base

  def self.logon(pass)
    pass == APP_CONFIG['password']
  end

end
