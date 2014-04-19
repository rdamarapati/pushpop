require 'pushpop'

EXAMPLE_TEMPLATES_DIR = File.expand_path('../templates', __FILE__)

job 'Pingpong check response report' do

  every 24.hours

  keen do
    event_collection  'checks'
    analysis_type     'average'
    target_property   'request.duration'
    timeframe         'last_24_hours'
    group_by          'check.name'
  end

  sendgrid do |response, step_responses|
    to 'josh+pushpop@keen.io'
    from 'josh+pushpop@keen.io'
    subject 'Pingpong Daily Response Time Report'
    body 'keen_sendgrid.html.erb', response, step_responses, EXAMPLE_TEMPLATES_DIR
    preview ENV['PREVIEW']
  end

end
