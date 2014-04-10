require 'logger'
require 'clockwork'
require 'pushover/job'
require 'pushover/step'

# require all plugins
Dir["#{File.expand_path('../plugins/*', __FILE__)}.rb"].each { |file|
  require file
}

module Pushover
  class << self
    cattr_accessor :logger
    cattr_accessor :jobs

    self.jobs = []

    def add_job(name=nil, &block)
      self.jobs.push(Job.new(name, &block))
      self.jobs.last
    end

    def run
      self.jobs.map &:run
    end

    def schedule
      self.jobs.map &:schedule
    end
  end
end

# add into main
def job(name=nil, &block)
  Pushover.add_job(name, &block)
end

Pushover.logger = lambda {
  logger = Logger.new($stdout)
  if ENV['DEBUG']
    logger.level = Logger::DEBUG
  elsif ENV['RACK_ENV'] == 'test'
    logger.level = Logger::FATAL
  else
    logger.level = Logger::INFO
  end
  logger
}.call

