require 'erb'

module Pushpop

  class Step

    TEMPLATES_DIRECTORY = File.expand_path('../../templates', __FILE__)

    class ERBContext
      attr_accessor :response
      attr_accessor :step_responses

      def initialize(response, step_responses)
        self.response = response
        self.step_responses = step_responses
      end

      def get_binding
        binding
      end
    end

    attr_accessor :name
    attr_accessor :plugin
    attr_accessor :block

    def initialize(name=nil, plugin=nil, &block)
      self.name = name || plugin || Pushpop.random_name
      self.plugin = plugin
      self.block = block
    end

    def template(filename, response, step_responses, directory=TEMPLATES_DIRECTORY)
      erb_context = ERBContext.new(response, step_responses)
      ERB.new(get_template_contents(filename, directory)).result(erb_context.get_binding)
    end

    def run(last_response=nil, step_responses=nil)
      block.call(last_response, step_responses)
    end

    private

    def get_template_contents(filename, directory)
      File.read(File.join(directory, filename))
    end

  end

end
