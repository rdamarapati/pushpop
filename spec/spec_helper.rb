require 'webmock/rspec'

$: << File.join(File.dirname(__FILE__), 'lib')

# require implementations of components first
Dir["#{File.expand_path('../../lib/*', __FILE__)}.rb"].each {|file| require file }

RSpec.configure do |config|
  config.before :each do
    KeenCron.jobs.clear
  end
end
