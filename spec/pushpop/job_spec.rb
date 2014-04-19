require 'spec_helper'

describe Pushpop::Job do

  let (:empty_job) { Pushpop::Job.new('foo') do end }
  let (:empty_step) { Pushpop::Step.new('bar') do end }

  describe '#register_plugins' do
    it 'should register a plugin' do
      Pushpop::Job.register_plugin('blaz', Class)
      Pushpop::Job.plugins['blaz'].should == Class
    end
  end

  describe '#initialize' do
    it 'should set a name and evaluate a block' do
      block_ran = false
      job = Pushpop::Job.new('foo') do block_ran = true end
      job.name.should == 'foo'
      job.every_duration.should be_nil
      job.every_options.should == {}
      block_ran.should be_true
    end

    it 'should auto-generate a name' do
      job = Pushpop::Job.new do end
      job.name.should_not be_nil
    end
  end

  describe '#every' do
    it 'should set duration and options' do
      job = empty_job
      job.every(10.seconds, at: '01:02')
      job.every_duration.should == 10
      job.every_options.should == { at: '01:02' }
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
      class FakeStep < Pushpop::Step
      end

      before do
        Pushpop::Job.register_plugin('blaz', FakeStep)
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
      job = Pushpop::Job.new('foo') do
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
      simple_job = Pushpop::Job.new('foo') do
        every frequency
        step 'track_times_run' do
          @times_run ||= 0
          @times_run += 1
        end
      end

      simple_job.schedule

      Clockwork.manager.tick(Time.now)
      simple_job.run.first.should == 2
      Clockwork.manager.tick(Time.now + frequency)
      simple_job.run.first.should == 4
    end
  end

  describe '#method_missing' do
    class FakeStep < Pushpop::Step
    end

    before do
    end

    it 'should assume its a registered plugin name and try to create a step' do
      Pushpop::Job.register_plugin('blaz', FakeStep)
      simple_job = job do
        blaz 'hi' do end
      end
      simple_job.steps.first.name.should == 'hi'
      simple_job.steps.first.class.should == FakeStep
    end

    it 'should not assume a name' do
      Pushpop::Job.register_plugin('blaz', FakeStep)
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
      }.to raise_error /undefined method/
    end
  end

end
