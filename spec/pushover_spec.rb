require 'spec_helper'

describe Pushover do

  describe 'setup' do
    it 'should add an jobs to the jobs list' do
      job 'Test Job' do
      end

      Pushover.jobs.length.should == 1
      Pushover.jobs.first.name.should == 'Test Job'
    end

    it 'should capture job steps' do
      job 'Test Job' do
        step 'Step One', :keen do
        end
      end

      job = Pushover.jobs.first
      job.steps.length.should == 1
      job.steps.first.name.should == 'Step One'
      job.steps.first.provider.should == :keen
    end

    it 'should capture frequency information' do
      job 'Test Job' do
        every 24.hours, at: '12:00'
      end

      job = Pushover.jobs.first
      job.every_duration.should == 24.hours
      job.every_options.should == { at: '12:00' }
    end
  end

  describe 'running jobs' do
    it 'should run each step, passing to each one the responses received so far' do
      job 'Test Job' do
        step 'Step One' do
          123456
        end
      end
      job 'Test Job 2' do
        step 'Step One' do
          654321
        end
      end

      Pushover.run!.should == [[123456], [654321]]
    end
  end
end