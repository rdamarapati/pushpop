require 'rubygems'
require 'clockwork'
require 'keen'

include Clockwork

require 'mail'
Mail.defaults do
  delivery_method :smtp, { :address   => "smtp.sendgrid.net",
                           :port      => 587,
                           :domain    => ENV['SENDGRID_DOMAIN'],
                           :user_name => ENV['SENDGRID_USERNAME'],
                           :password  => ENV['SENDGRID_PASSWORD'],
                           :authentication => 'plain',
                           :enable_starttls_auto => true }
end

def send_mail(_subject, _html_body, _text_body=nil)
  Mail.deliver do
    to 'Josh Dzielak <josh@keen.io>'
    from 'keen-cron <alerts@keen.io>'
    subject _subject
    text_part do
      body _html_body
    end
    html_part do
      content_type 'text/html; charset=UTF-8'
      body _text_body || _html_body
    end
  end
end

handler do |job|
  puts job
end

every(1.minute, 'count.failure') do
  result = Keen.count('checks',
                   timeframe: 'last_1_minute',
                   filters: [{
                     property_name: "response.status",
                     property_value: 400,
                     operator: "gte"
                   }])

  puts "count.failure: #{result}"

  if result != 0
    send_mail "count.failure is non-zero!", result
  end
end

every(1.minute, 'count.timeout') do
  result = Keen.count('checks',
                   timeframe: 'last_1_minute',
                   filters: [{
                     property_name: "response.status",
                     property_value: 0,
                     operator: "eq"
                   }])

  puts "count.timeout: #{result}"

   if result != 0
     send_mail "count.timeout is non-zero!", result
   end
end

error_handler do |error|
  puts error
end
