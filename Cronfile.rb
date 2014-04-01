require 'lib/keencron'
require 'plugins/keen'
require 'plugins/sendgrid'

module KeenCron

  job 'Daily Email' do

    every 24.hours, at: '00:00'

    step 'keen', 'query' do
      event_collection 'signups'
      analysis_type 'count'
      timeframe 'last_24_hours'
    end

    step 'send_if_nonzero', nil do |response|
      return true if response[:result] > 0
    end

    step 'sendgrid' do |response|
      to 'josh@keen.io'
      subject '#{response[:result]} Signups Today!'
      template 'foo.html.erb', data: response
    end

  end

end