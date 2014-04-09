require 'logger'
require 'clockwork'
require 'pushover/job'
require 'pushover/step'

class Pushover
  class << self
    attr_accessor :logger

    @@jobs = []

    def add_job(name, &block)
      @@jobs.push(Job.new(name, &block))
    end

    def jobs
      @@jobs
    end

    def run
      @@jobs.map &:run
    end

    def schedule
      @@jobs.map &:schedule
    end
  end
end

# add into main
def job(name, &block)
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

