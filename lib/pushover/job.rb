module Pushover

  class Job

    class << self

      cattr_accessor :step_providers
      self.step_providers = {}

      def register_provider(name, klass)
        self.step_providers ||= {}
        self.step_providers[name.to_s] = klass
      end
    end

    attr_accessor :name
    attr_accessor :every_duration
    attr_accessor :every_options
    attr_accessor :steps

    def initialize(name, &block)
      self.name = name
      self.steps = []
      self.every_options = {}
      self.instance_eval(&block)
    end

    def every(duration, options={})
      self.every_duration = duration
      self.every_options = options
    end

    def step(name, provider=nil, &block)
      if provider

        provider_klass = self.class.step_providers[provider]
        raise "No provider configured for #{provider}" unless provider_klass

        self.add_step(provider_klass.new(name, provider, &block))
      else
        self.add_step(Step.new(name, provider, &block))
      end
    end

    def add_step(step)
      self.steps.push(step)
    end

    def schedule
      Clockwork.manager.every(every_duration, name, every_options) do
        run
      end
    end

    def run
      step_responses = []
      self.steps.each do |step|
        step_response = step.run(step_responses)
        step_response == false ?
            return : step_responses.unshift(step_response)
      end

      Pushover.logger.debug("#{name}: #{step_responses.first}")

      step_responses
    end

  end

end

