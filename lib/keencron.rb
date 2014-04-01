module KeenCron
  class << self
    @@jobs = []

    def jobs
      @@jobs
    end

    def job(name, &block)
      @@jobs.push(Job.new(name, &block))
    end

    def run!
      @@jobs.map &:run!
    end

    def schedule!
      @@jobs.map &:schedule!
    end
  end
end