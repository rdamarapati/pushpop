require 'spec_helper'

describe Pushover::Step do

  describe 'initialize' do

    it 'should set a name, a provider, and a block' do
      empty_proc = Proc.new {}
      step = Pushover::Step.new('foo', 'foopie', &empty_proc)
      step.name.should == 'foo'
      step.provider.should == 'foopie'
      step.block.should == empty_proc
    end

    it 'should auto-generate a name if not given' do
      empty_proc = Proc.new {}
      step = Pushover::Step.new(&empty_proc)
      step.name.should_not be_nil
      step.provider.should be_nil
      step.block.should == empty_proc
    end

    it 'should not require a provider' do
      empty_proc = Proc.new {}
      step = Pushover::Step.new('foo', &empty_proc)
      step.name.should == 'foo'
      step.block.should == empty_proc
    end

  end

  describe 'run' do

    it 'should call the block with the same args' do
      arg1, arg2 = nil
      times_run = 0
      empty_proc = Proc.new { |a1, a2| arg1 = a1; arg2 = a2; times_run += 1 }
      step = Pushover::Step.new('foo', &empty_proc)
      step.run('foo', 'bar')
      arg1.should == 'foo'
      arg2.should == 'bar'
      times_run.should == 1
    end

  end

end
