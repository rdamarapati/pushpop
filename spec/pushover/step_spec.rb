require 'spec_helper'

describe Step do

  describe 'initialize' do

    it 'should set a name, a provider, and a block' do
      empty_proc = Proc.new {}
      step = Step.new('foo', 'foopie', &empty_proc)
      step.name.should == 'foo'
      step.provider.should == 'foopie'
      step.block.should == empty_proc
    end

    it 'should not require a provider' do
      empty_proc = Proc.new {}
      step = Step.new('foo', &empty_proc)
      step.name.should == 'foo'
      step.block.should == empty_proc
    end

  end

  describe 'run' do

    it 'should call the block' do
      times_run = 0
      empty_proc = Proc.new { times_run += 1 }
      step = Step.new('foo', &empty_proc)
      step.run
      times_run.should == 1
    end

  end

end
