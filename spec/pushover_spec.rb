require 'spec_helper'

describe 'job' do
  job 'foo-main' do end
  Pushover.jobs.first.name.should == 'foo-main'
end

describe Pushover do

  describe 'add_job' do
    it 'should add a job to the list' do
      empty_proc = Proc.new {}
      Pushover.add_job('foo', &empty_proc)
      Pushover.jobs.first.name.should == 'foo'
    end
  end
end