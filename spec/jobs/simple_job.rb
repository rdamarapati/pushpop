require 'pushpop'

job 'Simple Math' do
  every 1.seconds
  step 'return 10' do 10 end
  step 'increase by 20' do |response|
    20 + response
  end
end
