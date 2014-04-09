require 'keen'

module Pushover

  class Keen

    attr_accessor :name

    attr_accessor :_event_collection
    attr_accessor :_analysis_type
    attr_accessor :_timeframe

    def initialize(&block)
      self.block = block
    end

    def run
      case self._analysis_type
        when 'count'
          Keen.count(self._event_collection, self.to_analysis_options)
      end
    end

    def to_analysis_options
      { :timeframe => self._timeframe }
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
end
