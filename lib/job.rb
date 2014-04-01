class Job

  attr_accessor :name
  attr_accessor :every_duration
  attr_accessor :every_options
  attr_accessor :steps

  def initialize(name, &block)
    self.name = name
    self.steps = []
    self.instance_eval(&block)
  end

  def every(duration, options={})
    self.every_duration = duration
    self.every_options = options
  end

  def step(name, provider=nil, &block)
    self.steps.push(Step.new(name, provider, &block))
  end

  def schedule!
  end

  def run!
    step_responses = []
    self.steps.each do |step|
      step_response = step.run!(step_responses)
      step_response == false ?
          return : step_responses.push(step_response)
    end
    step_responses
  end
end

