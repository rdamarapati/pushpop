$stdout.sync = true

$: << File.join(File.dirname(__FILE__), './lib')

begin
  require 'rspec/core/rake_task'
  desc 'Run Rspec unit tests'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end

  task default: :spec
rescue LoadError
end

namespace :jobs do
  desc 'Describe jobs'
  task :describe, :pushfile do |task, args|
    pushfile = args[:pushfile] || 'Pushfile'
    load "#{File.dirname(__FILE__)}/#{pushfile}"
    Pushpop.jobs.each do |job|
      puts job.name
    end
  end

  task :test, :pushfile do |task, args|
    pushfile = args[:pushfile] || 'Pushfile'
    load "#{File.dirname(__FILE__)}/#{pushfile}"
    Pushpop.run
  end

  task :run, :pushfile do |task, args|
    pushfile = args[:pushfile] || 'Pushfile'
    load "#{File.dirname(__FILE__)}/#{pushfile}"
    Pushpop.schedule
    Clockwork.manager.run
  end
end
