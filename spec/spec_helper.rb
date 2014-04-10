require 'webmock/rspec'

$: << File.join(File.dirname(__FILE__), '../lib')

require 'pushover'

RSpec.configure do |config|
  config.before :each do
    Pushover.jobs.clear
    Pushover::Job.step_plugins.clear
  end
end
