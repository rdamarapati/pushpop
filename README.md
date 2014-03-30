# keen-cron

Trigger actions based on the result of queries made to Keen IO at regular intervals.

keen-cron can be used for a variety of use cases:

+ Send out a daily email of your metrics
+ Send an alerting email or SMS when a metric is out-of-whack
+ Eagerly fetch metrics at an interval to keep a cache fresh

Here's an example `Cronfile` that runs a query every five minutes and
sends an email if the query result is non-zero.

``` ruby
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
```

keen-cron uses Clockwork. Clockwork creates a lightweight, long-running
Ruby process that does work at configurable intervals. No confusing
cron syntax required.

keen-cron adds some special macros on top of Clockwork to make
implementing a query-then-act pattern easy.

Taking action can be made conditional on the result of a query. This is
useful for generating notifications when anomalous conditions arise.

### Configuration

keen-rules can be configured in code or loaded via a JSON file.
Here's an example JSON:


``` json
{
  "rules" : [{
    "name" : "CheckFailed",
    "description" : "Send an email if a URL check failed",
    "frequency" : "300",
    "query" : {
      "analysis_type" : "count",
      "event_collection" : "checks",
      "timeframe": "last_5_minutes",
      "filters" : [{
        "property_name" : "response.code",
        "operator" : "ne",
        "property_value" : "200"
      }]
    },
    "tests" : [{
      "path" : "result",
      "op" : "more",
      "value" : "0"
    }],
    "actions" : [{
      "type" : "sendgrid",
      "to" : "josh@keen.io",
      "subject" : "[error] A URL Check has failed"
    }]
  }]
}
```

Along with name and description metadata, rules have 3 main parts: the query to
run, the tests to perform on the response body, and the actions to take.

### Usage

keen-rules can be used

### Test-free

You can also use keen-rules to email query results at an interval.
