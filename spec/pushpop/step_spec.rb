require 'spec_helper'

SPEC_TEMPLATES_DIRECTORY = File.expand_path('../../templates', __FILE__)

describe Pushpop::Step do

  describe 'initialize' do

    it 'should set a name, a plugin, and a block' do
      empty_proc = Proc.new {}
      step = Pushpop::Step.new('foo', 'foopie', &empty_proc)
      step.name.should == 'foo'
      step.plugin.should == 'foopie'
      step.block.should == empty_proc
    end

    it 'should auto-generate a name if not given and plugin not given' do
      empty_proc = Proc.new {}
      step = Pushpop::Step.new(&empty_proc)
      step.name.should_not be_nil
      step.plugin.should be_nil
      step.block.should == empty_proc
    end

    it 'should set name to plugin name if not given' do
      empty_proc = Proc.new {}
      step = Pushpop::Step.new(nil, 'keen', &empty_proc)
      step.name.should == 'keen'
      step.plugin.should == 'keen'
      step.block.should == empty_proc
    end

    it 'should not require a plugin' do
      empty_proc = Proc.new {}
      step = Pushpop::Step.new('foo', &empty_proc)
      step.name.should == 'foo'
      step.block.should == empty_proc
    end

  end

  describe 'run' do

    it 'should call the block with the same args' do
      arg1, arg2 = nil
      times_run = 0
      empty_proc = Proc.new { |a1, a2| arg1 = a1; arg2 = a2; times_run += 1 }
      step = Pushpop::Step.new('foo', &empty_proc)
      step.run('foo', 'bar')
      arg1.should == 'foo'
      arg2.should == 'bar'
      times_run.should == 1
    end

    it 'should execute the block bound to the step' do
      _self = nil
      step = Pushpop::Step.new(nil, nil) do
        _self = self
      end
      step.run
      _self.should == step
    end

  end

  describe 'template' do
    it 'should render the named template with the response binding' do
      step = Pushpop::Step.new
      step.template('spec.html.erb', 500, {}, SPEC_TEMPLATES_DIRECTORY).strip.should == '<pre>500</pre>'
    end

    it 'should render the named template with the step_response binding' do
      step = Pushpop::Step.new
      step.template('spec.html.erb', nil, { test: 600 }, SPEC_TEMPLATES_DIRECTORY).strip.should == '<pre>600</pre>'
    end
  end

end
