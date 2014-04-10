module Pushover

  class Step

    attr_accessor :name
    attr_accessor :plugin
    attr_accessor :block

    def initialize(name=nil, plugin=nil, &block)
      self.name = name || plugin || Pushover.random_name
      self.plugin = plugin
      self.block = block
    end

    def run(last_response=nil, step_responses=nil)
      block.call(last_response, step_responses)
    end

  end

end
