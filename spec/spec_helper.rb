require 'webmock/rspec'

$: << File.join(File.dirname(__FILE__), '../lib')

require 'pushpop'

RSpec.configure do |config|
  config.before :each do
    Pushpop.jobs.clear
    Pushpop::Job.step_plugins.clear
  end
end
