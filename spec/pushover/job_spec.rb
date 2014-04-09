require 'spec_helper'

describe Pushover::Job do

  let (:empty_job) { Pushover::Job.new('foo') do end }
  let (:empty_step) { Pushover::Step.new('bar') do end }

  describe '#register_providers' do
    it 'should register a provider' do
      Pushover::Job.register_provider('blaz', Class)
      Pushover::Job.step_providers['blaz'].should == Class
    end
  end

  describe '#initialize' do
    it 'should set a name and evaluate a block' do
      block_ran = false
      job = Pushover::Job.new('foo') do block_ran = true end
      job.name.should == 'foo'
      job.every_duration.should be_nil
      job.every_options.should == {}
      block_ran.should be_true
    end
  end

  describe '#every' do
    it 'should set duration and options' do
      job = empty_job
      job.every(10.seconds, :at => '01:02')
      job.every_duration.should == 10
      job.every_options.should == { :at => '01:02' }
    end
  end

  describe '#step' do
    it 'should add the step to the internal list of steps' do
      empty_proc = Proc.new {}
      job = empty_job
      job.step('blah', &empty_proc)
      job.steps.first.name.should == 'blah'
      job.steps.first.block.should == empty_proc
    end

    context 'provider specified' do
      class FakeStep < Pushover::Step
      end

      before do
        Pushover::Job.register_provider('blaz', FakeStep)
      end

      it 'should use the registered provider to instantiate the class' do
        empty_proc = Proc.new {}
        job = empty_job
        job.step('blah', 'blaz', &empty_proc)
        job.steps.first.name.should == 'blah'
        job.steps.first.provider.should == 'blaz'
        job.steps.first.class.should == FakeStep
        job.steps.first.block.should == empty_proc
      end

      it 'should throw an exception for an unregistered provider' do
        empty_proc = Proc.new {}
        job = empty_job
        expect {
          job.step('blah', 'blaze', &empty_proc)
        }.to raise_error /No provider configured/
      end
    end
  end

  describe '#run' do
    it 'should call each step with the response to the previous' do
      job = Pushover::Job.new('foo') do
        step 'one' do
          10
        end

        step 'two' do |response|
          response.first + 20
        end
      end
      job.run.should == [30, 10]
    end
  end

  describe '#schedule' do
    it 'should add the job to clockwork' do
      frequency = 1.seconds
      simple_job = Pushover::Job.new('foo') do
        every frequency
        def times_run
          @times_run ||= 0
        end
        step 'track_times_run' do
          @times_run += 1
        end
      end

      simple_job.schedule

      simple_job.times_run.should == 0
      Clockwork.manager.tick(Time.now)
      simple_job.times_run.should == 1
      Clockwork.manager.tick(Time.now + frequency)
      simple_job.times_run.should == 2
    end
  end

end
