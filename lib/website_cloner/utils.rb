require 'logger'
require 'set'

module WebsiteCloner
  module Utils
    def self.logger
      @logger ||= Logger.new(STDOUT).tap do |log|
        log.formatter = proc do |severity, datetime, progname, msg|
          color = case severity
                  when 'INFO' then "\e[32m"  # Green
                  when 'WARN' then "\e[33m"  # Yellow
                  when 'ERROR' then "\e[31m" # Red
                  else "\e[0m"               # Default
                  end
          "#{color}[#{severity}] #{msg}\e[0m\n"
        end
      end
    end
  end
end
