class Step
  attr_accessor :name
  attr_accessor :provider
  attr_accessor :block

  def initialize(name, provider=nil, &block)
    self.name = name
    self.provider = provider
    self.block = block
  end

  def run!(step_responses=nil)
    block.call(step_responses)
  end
end

