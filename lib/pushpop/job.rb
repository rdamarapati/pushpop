module Pushpop

  class Job

    class << self

      cattr_accessor :step_plugins
      self.step_plugins = {}

      def register_plugin(name, klass)
        self.step_plugins ||= {}
        self.step_plugins[name.to_s] = klass
      end

    end

    attr_accessor :name
    attr_accessor :every_duration
    attr_accessor :every_options
    attr_accessor :steps

    def initialize(name=nil, &block)
      self.name = name || Pushpop.random_name
      self.steps = []
      self.every_options = {}
      self.instance_eval(&block)
    end

    def every(duration, options={})
      self.every_duration = duration
      self.every_options = options
    end

    def step(name=nil, plugin=nil, &block)
      if plugin

        plugin_klass = self.class.step_plugins[plugin]
        raise "No plugin configured for #{plugin}" unless plugin_klass

        self.add_step(plugin_klass.new(name, plugin, &block))
      else
        self.add_step(Step.new(name, plugin, &block))
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
      Pushpop.logger.debug("#{name}: #{step_responses}")

      # return the last response and all responses
      [last_response, step_responses]
    end

    def method_missing(method, *args, &block)
      plugin_class = self.class.step_plugins[method.to_s]

      name = args[0]
      plugin = method.to_s

      if plugin_class
        step(name, plugin, &block)
      else
        raise "No plugin defined until name #{method}"
      end
    end

  end

end

