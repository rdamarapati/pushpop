require 'lib/keencron'
require 'keen'
require 'plugins/keen'
require 'plugins/sendgrid'

job "Daily Email" do

  every 24.hours, at: "00:00"

  step "keen" do
    event_collection "signups"
    analysis_type "count"
  end

  step "send_if_nonzero" do |response|
    return true if response[:result] > 0
  end

  step "sendgrid" do |response|
    to "josh@keen.io"
    subject "#{response[:result]} Signups Today!"
    template "foo.html.erb"
  end

end