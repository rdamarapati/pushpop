require 'spec_helper'

describe Pushover::Job do

  let (:empty_job) { Pushover::Job.new('foo') do end }
  let (:empty_step) { Pushover::Step.new('bar') do end }

  describe '#register_plugins' do
    it 'should register a plugin' do
      Pushover::Job.register_plugin('blaz', Class)
      Pushover::Job.step_plugins['blaz'].should == Class
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

    it 'should auto-generate a name' do
      job = Pushover::Job.new do end
      job.name.should_not be_nil
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

    context 'plugin specified' do
      class FakeStep < Pushover::Step
      end

      before do
        Pushover::Job.register_plugin('blaz', FakeStep)
      end

      it 'should use the registered plugin to instantiate the class' do
        empty_proc = Proc.new {}
        job = empty_job
        job.step('blah', 'blaz', &empty_proc)
        job.steps.first.name.should == 'blah'
        job.steps.first.plugin.should == 'blaz'
        job.steps.first.class.should == FakeStep
        job.steps.first.block.should == empty_proc
      end

      it 'should throw an exception for an unregistered plugin' do
        empty_proc = Proc.new {}
        job = empty_job
        expect {
          job.step('blah', 'blaze', &empty_proc)
        }.to raise_error /No plugin configured/
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
          response + 20
        end
      end
      job.run.should == [30, { 'one' => 10, 'two' => 30 }]
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

  describe '#method_missing' do
    class FakeStep < Pushover::Step
    end

    before do
    end

    it 'should assume its a registered plugin name and try to create a step' do
      Pushover::Job.register_plugin('blaz', FakeStep)
      simple_job = job do
        blaz 'hi' do end
      end
      simple_job.steps.first.name.should == 'hi'
      simple_job.steps.first.class.should == FakeStep
    end

    it 'should not assume a name' do
      Pushover::Job.register_plugin('blaz', FakeStep)
      simple_job = job do
        blaz do end
      end
      simple_job.steps.first.name.should_not be_nil
      simple_job.steps.first.plugin.should == 'blaz'
      simple_job.steps.first.class.should == FakeStep
    end

    it 'should raise an exception if there is no registered plugin' do
      expect {
        job do
          blaze do end
        end
      }.to raise_error /No plugin defined/
    end
  end

end
