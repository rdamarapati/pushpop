module Pushover

  class Step

    class << self
      def random_step_name
        (0...8).map { (65 + rand(26)).chr }.join
      end
    end

    attr_accessor :name
    attr_accessor :provider
    attr_accessor :block

    def initialize(name=nil, provider=nil, &block)
      self.name = name || self.class.random_step_name
      self.provider = provider
      self.block = block
    end

    def run(last_response=nil, step_responses=nil)
      block.call(last_response, step_responses)
    end

  end

end
