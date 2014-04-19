require 'spec_helper'

describe 'run a job end to end' do
  it 'should run and return template contents' do
    require File.expand_path('../jobs/simple_job', __FILE__)
    Pushpop.jobs.length.should == 1
    Pushpop.jobs.first.run.should == [30, { "return 10" => 10, "increase by 20" => 30}]
  end
end