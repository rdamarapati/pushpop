# Sample job that just does math
# See examples folder for more examples!

require 'pushpop'

# now create any number of jobs with any number of steps

# this job run every second
# it will add 20 to 10 and return 30
job 'Simple Math' do
  every 1.seconds
  step do 10 end
  step do |response|
    20 + response
  end
  step do |response|
    puts 'Hey Pushpop, let\'s do a math!'
    puts template 'first_template.html.erb', response
  end
end
