require 'spec_helper'
require 'plugins/keen'

describe Pushover::Keen do
  describe '#initialize' do
    it 'should remember the block' do
      empty_proc = Proc.new {}
      step = Pushover::Keen.new('one', &empty_proc)
      step.block.should == empty_proc
    end
  end

  describe '#configure' do
    it 'should set params for each' do
      step = Pushover::Keen.new('one') do
        event_collection 'signups'
        analysis_type 'count'
        timeframe 'last_3_days'
      end
      step.configure
      step._event_collection.should == 'signups'
      step._analysis_type.should == 'count'
      step._timeframe.should == 'last_3_days'
    end
  end

  describe '#run' do
    it 'should run the query based on the analysis type' do
      Keen.stub(:count).with('signups', { :timeframe => 'last_3_days' }).and_return(365)
      step = Pushover::Keen.new('one') do
        event_collection 'signups'
        analysis_type 'count'
        timeframe 'last_3_days'
      end
      response = step.run
      response.should == 365
    end
  end

  describe '#to_analysis_options' do
    it 'should include various options' do
      step = Pushover::Keen.new('one') do end
      step._timeframe = 'last_4_days'
      step.to_analysis_options.should == {
          timeframe: 'last_4_days'
      }
    end

    it 'should not include nils' do
      step = Pushover::Keen.new('one') do end
      step.to_analysis_options.should == {}
    end
  end
end