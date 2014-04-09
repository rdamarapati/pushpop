require 'clockwork'
require 'pushover/job'
require 'pushover/step'

class Pushover
  class << self
    @@jobs = []

    def add_job(name, &block)
      @@jobs.push(Job.new(name, &block))
    end

    def jobs
      @@jobs
    end

    def run!
      @@jobs.map &:run!
    end

    def schedule!
      @@jobs.map &:schedule!
    end
  end
end

# add into main
def job(name, &block)
  Pushover.add_job(name, &block)
end
