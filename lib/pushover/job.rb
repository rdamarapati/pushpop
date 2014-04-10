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

      # track the last response, and all responses
      last_response = nil
      step_responses = {}

      self.steps.each do |step|

        # track the last_response and all responses
        last_response = step.run(last_response, step_responses)
        step_responses[step.name] = last_response

        # abort unless this step returned truthily
        return unless last_response
      end

      # log responses in debug
      Pushover.logger.debug("#{name}: #{step_responses}")

      # return the last response and all responses
      [last_response, step_responses]
    end

  end

end

