require 'vendor/plugins/thinking-sphinx/recipes/thinking_sphinx'

set :application, "Terra-Livre"
set :repository,  "git://github.com/marciomr/Terra-Livre.git"

set :scm, :git

set :user, "bibliotecaterralivre"
set :use_sudo, false

set :deploy_to, "/var/sites/bibliotecaterralivre/rails"
set :deploy_via, :remote_cache

set :default_environment, {
  'PATH' => "#{deploy_to}/.rvm/gems/ruby-1.8.7-p302/bin:~/.rvm/bin:$PATH",
  'RUBY_VERSION' => 'ruby 1.8.7',
  'GEM_HOME'     => "#{deploy_to}/.rvm/gems/ruby-1.8.7-p302",
  'GEM_PATH'     => "#{deploy_to}/.rvm/gems/ruby-1.8.7-p302",
}

server "clarice.sarava.org", :app, :web, :db, :primary => true
set :port, 2206

namespace :gems do
  desc "Install gems."
  task :install do
    run "cd #{deploy_to}/current; RAILS_ENV=production rake gems:install"
  end
end

namespace :deploy do
  desc "Restart the server."
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  desc "Symlink shared files to the current path."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/"
    run "ln -nfs #{shared_path}/config/sphinx.yml #{release_path}/config/"
    run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/"
    run "ln -nfs #{shared_path}/config/environment.rb #{release_path}/config/"
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx/"
  end
  
  desc "Update the crontab file."  
  task :update_crontab, :roles => :db do  
    run "cd #{release_path}; whenever --update-crontab #{application} --set environment=production"  
  end  
end

desc "Watch the production log on the application server."
task :watch_logs, :roles => :app do
  log_file = "#{shared_path}/log/production.log"
  run "tail -f #{log_file}" do |channel, stream, data|
    puts data if stream == :out 
    if stream == :err 
      puts "[Error: #{channel[:host]}] #{data}"
      break
    end     
  end
end

namespace :backup do
  desc "Save a copy of rss file in the server."
  task :remote do
    run "cd #{current_path}; RAILS_ENV=production rake backup:save"
  end
  desc "Backup locally the backups folder."
  task :local do
    run "tar -cvf #{current_path}/tmp/backups.tar #{deploy_to}/backups"
    run "gzip #{current_path}/tmp/backups.tar"
    get "#{current_path}/tmp/backups.tar.gz", "/home/marciomr/Documentos/Terra-Livre/backups.tar.gz" 
    run "rm -f #{current_path}/tmp/backups.tar.gz"
  end
  desc "Recover the last rss file."
  task :rollback do
    run "cd #{current_path}; RAILS_ENV=production rake backup:rollback"
  end
  task :last do
    run "cd #{current_path}; RAILS_ENV=production rake backup:show_last" do |channel, stream, data|
      puts data
    end
  end
end

before "deploy:update_code", "thinking_sphinx:stop"

after "deploy:update_code", "deploy:symlink_shared"
#after "deploy:symlink_shared", "gems:install"
#after "deploy:symlink_shared", "deploy:update_crontab"  

#after "gems:install", "deploy:migrate"
#after "deploy:migrate", "thinking_sphinx:configure"
#after "deploy:migrate", "thinking_sphinx:start"
after "deploy:symlink_shared", "thinking_sphinx:start"
