module Pushover

  class Step

    attr_accessor :name
    attr_accessor :provider
    attr_accessor :block

    def initialize(name=nil, provider=nil, &block)
      self.name = name || provider || Pushover.random_name
      self.provider = provider
      self.block = block
    end

    def run(last_response=nil, step_responses=nil)
      block.call(last_response, step_responses)
    end

  end

end
