require 'spec_helper'

describe 'job' do
  job 'foo-main' do end
  Pushpop.jobs.first.name.should == 'foo-main'
end

describe Pushpop do

  describe 'add_job' do
    it 'should add a job to the list' do
      empty_proc = Proc.new {}
      Pushpop.add_job('foo', &empty_proc)
      Pushpop.jobs.first.name.should == 'foo'
    end
  end
end