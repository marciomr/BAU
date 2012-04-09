class ApplicationController < ActionController::Base
  helper_method :current_user, :admin, :admin?, :guest?, :restricted_to
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5f2f9061bb334aa869d4717f2779655e'

  protected
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def admin
    @admin ||= User.find(1)
  end 

  def admin?
    current_user == admin
  end
  
  def guest?
    current_user.nil?
  end

  def unautorized!(path = login_path)
    session[:return_to] = request.url
    redirect_to path, :alert => "Acesso negado!"
  end  
  
  def access_restricted_to(users)
    users = [users] if !users.kind_of?(Array)
    
    if !guest? && users.include?(current_user)
      yield if block_given?
    else
      unautorized!
    end
  end
  
  def restricted_to(users)
    users = [users] if !users.kind_of?(Array)
    
    users.each do |user|
      if !guest? && user.try(:id) == current_user.id
        yield
      end
    end
  end
  
  def call_rake(ns, task, options = {})
    options[:rails_env] = Rails.env
    args = options.map{ |n, v| "#{n.to_s.upcase}='#{v}'" }
    # should put the complete path for rake
    system "rake #{ns}:#{task} #{args.join(' ')} --trace >> #{Rails.root}/log/rake.log &" 
  end
end
