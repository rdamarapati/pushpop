require 'pushpop'

job 'Text pageviews every 24 hours' do

  every 24.hours

  keen do
    event_collection  'pageviews'
    analysis_type     'count'
    timeframe         'last_24_hours'
  end

  twilio do |_, step_responses|
    to    ENV['EXAMPLE_TWILIO_TO']
    body  "There were #{step_responses['keen']} pageviews today!"
  end

end
