# keen-cron

Trigger actions based on the result of queries made to Keen IO.

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
