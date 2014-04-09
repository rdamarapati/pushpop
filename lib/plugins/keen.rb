require 'keen'

module Pushover

  class Keen < Step

    attr_accessor :name

    attr_accessor :_event_collection
    attr_accessor :_analysis_type
    attr_accessor :_timeframe

    def run(step_responses=nil)
      self.configure(step_responses)
      ::Keen.send(self._analysis_type, self._event_collection, self.to_analysis_options)
    end

    def configure(step_responses=nil)
      self.instance_exec(step_responses, &block)
    end

    def to_analysis_options
      { :timeframe => self._timeframe }.delete_if { |_, v| v.nil? }
    end

    def event_collection(event_collection)
      self._event_collection = event_collection
    end

    def analysis_type(analysis_type)
      self._analysis_type = analysis_type
    end

    def timeframe(timeframe)
      self._timeframe = timeframe
    end

  end

  Pushover::Job.register_provider('keen', Keen)
end
