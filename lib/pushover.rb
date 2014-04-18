require 'logger'
require 'clockwork'
require 'pushpop/job'
require 'pushpop/step'

# require all plugins
Dir["#{File.expand_path('../plugins/*', __FILE__)}.rb"].each { |file|
  require file
}

module Pushpop
  class << self
    cattr_accessor :logger
    cattr_accessor :jobs

    # for jobs and steps
    def random_name
      (0...8).map { (65 + rand(26)).chr }.join
    end

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
  Pushpop.add_job(name, &block)
end

Pushpop.logger = lambda {
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

