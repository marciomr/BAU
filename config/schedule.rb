# Example:
#
# set :output, "/path/to/my/cron_log.log"

every 1.day do
  rake "backup:save"
end

every :reboot do  
  rake "thinking_sphinx:start"  
end  

# Learn more: http://github.com/javan/whenever
