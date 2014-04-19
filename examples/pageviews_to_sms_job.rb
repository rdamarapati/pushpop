require 'pushpop'

job 'Text pageviews every 24 hours' do

  every 24.hours

  keen 'load_pageviews' do
    event_collection  'pageviews'
    analysis_type     'count'
    timeframe         'last_24_hours'
  end

  twilio 'send notification' do |response|
    to    ENV['EXAMPLE_TWILIO_TO']
    body  "There were #{response} pageviews today!"
  end

end
