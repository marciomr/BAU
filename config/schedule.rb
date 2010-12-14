# Example:
#
# set :output, "/path/to/my/cron_log.log"

every 1.day do
  rake "backup:save"
end

# Learn more: http://github.com/javan/whenever
