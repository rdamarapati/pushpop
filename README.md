# Pushpop
[![Build Status](https://travis-ci.org/keenlabs/pushpop.svg)](https://travis-ci.org/keenlabs/pushpop)
[![Dependency Status](https://gemnasium.com/keenlabs/pushpop.svg)](https://gemnasium.com/keenlabs/pushpop)

Send emails & notifications in response to analytics events.
<hr>
<img src="http://f.cl.ly/items/1I421w263a10340a0u2q/Screen%20Shot%202014-04-16%20at%204.35.47%20PM.png" width="45%" alt="Pingpong Daily Response Time Report">
&nbsp;&nbsp;&nbsp;
<img src="http://f.cl.ly/items/3F3X2s2d2A1I1o0V3p1n/image.png" width="45%" alt="There were 5402 Pageviews today!">
<hr>
Here are some ways to use Pushpop:

+ Send a daily metrics email
+ Send an SMS in response to key business events
+ Alert when a metric has increased or decreased

Pushpop currently includes plugins for [Keen IO](https://keen.io/), [Twilio](https://twilio.com/), and [Sendgrid](https://sendgrid.com/).
Pushpop is plugin-based, and our goal is to add support for more data sources and messaging systems. See [Contributing](#Contributing) below.

Pushpop works great with [Pingpong](https://github.com/keenlabs/pingpong.git), another open source project from your pals at Keen IO. Pingpong pings URLs at various frequencies and records response information as a Keen event.
Pairing Pushpop with Pingpong makes it easy to get custom alerts when Pingpong checks fail. And it's one hell of an alliteration.

### Usage

The core building blocks of Pushpop are jobs and steps. Jobs consist of multiple steps. Jobs are defined in a Ruby file.

Here's a job file that runs a Keen IO analysis every day at midnight, then sends an SMS containing the results:

``` ruby
require 'pushpop'

job do

  every 24.hours, at: '00:00'

  keen do
    event_collection 'pageviews'
    analysis_type 'count'
    timeframe 'last_24_hours'
  end

  twilio do |response|
    to '+18005555555'
    body "There were #{response} pageviews today!"
  end

end
```

In the example above, the `keen` step runs first and does a count of `pageviews` over the last 24 hours.
The number of `pageviews` is passed into the `twilio` step, which sends an SMS to the provided phone number.

### Local setup

Setting up your own Pushpop instance is very easy. The only prerequisite is a working Ruby installation.

First clone or fork this repository, then install dependencies:

``` shell
$ git clone git@github.com:keenlabs/pushpop.git
$ cd pushpop
$ gem install bundler
$ bundle install
```

Now you should be able to run a simple job. There's one defined in `jobs/example.rb`. Run all jobs in the `jobs` folder once using the
`jobs:run_once` rake task.

``` shell
$ bundle exec rake jobs:run_once
```

Any output of the job(s) will be printed to the console and the program will then exit.

Another rake task, `jobs:run`, will run the jobs indefinitely at the intervals you've defined.

``` shell
$ bundle exec rake jobs:run
```

Pushpop uses [Clockwork](https://github.com/tomykaira/clockwork) to schedule jobs. Clockwork creates a lightweight, long-running Ruby process that does work at configurable intervals. It doesn't install anything into cron,
and there's no confusing cron syntax required. It will run anywhere a Ruby app can, Heroku included.

This rake task starts a Clockwork scheduler that will run indefinitely until it is killed. It runs each job at the times specified.

You can also run a specific job file. Just add an argument to the rake task:

``` shell
$ bundle exec rake jobs:run_once[jobs/other_job.rb]
$ bundle exec rake jobs:run[jobs/other_job.rb]
```

The example job isn't very interesting. You should change it to add the tasks you want to run. If you change it,
make sure to commit before you deploy.

``` shell
$ git add jobs
$ git commit -m 'Added my jobs'
```

### Deployment

Here's how to deploy to Heroku.

First, create a new Heroku app. Make sure you're within your `pushpop` project directory.

``` shelll
$ heroku create
```

Now, upload configuration to your Heroku app. If you're using Keen and Sendgrid, you'll need to specify
the environment variables they expect. (You can also add `keen` and `sendgrid` as Heroku add-ons.)

``` shell
$ echo 'KEEN_PROJECT_ID=<my-project-id>'   >> .env
$ echo 'KEEN_READ_KEY=<my-read-key>'       >> .env
$ echo 'SENDGRID_USERNAME=<my-username>'   >> .env
$ echo 'SENDGRID_PASSWORD=<my-password>'   >> .env
$ echo 'SENDGRID_DOMAIN=heroku.com'        >> .env
$ heroku config:push                       # make sure heroku-config plugin is installed
```

Now push to Heroku:

```
$ git push heroku master
```

Lastly, make sure you have the right processes running. Pushpop uses 1 worker (see the `Procfile`).

``` shell
$ heroku scale worker=1
```

Your Pushpop should be up and running. Tail the Heroku logs to see your jobs run:

``` shell
$ heroku logs --tail
```

### The Pushpop DSL + API

Steps and jobs are the heart of the Pushpop DSL (domain-specific language). Any file can contain one or more jobs,
and each job contain one or more steps.

#### Jobs

Jobs have the following attributes:

+ `name`: (optional) something that describe the job, useful in logs
+ `every_duration`: the frequency at which to run the job
+ `every_options`: options related to when the job runs
+ `steps`: the ordered list of steps to run

These attributes are easily specified with the DSL's block syntax. Here's an example:

``` ruby
job 'print job' do
  every 5.minutes
  step do
    puts "5 minutes later..."
  end
end
```

Inside of a `job` configuration block, steps are added by using the `step` method. They can also be
added by using a method registered by a plugin, like `keen` or `twilio`. For more information, see [Plugins](#plugins).

The frequency of the job is set via the `every` method. This is basically a passthrough to Clockwork.
Here are some cool things you can do:

``` ruby
every 5.seconds
every 24.hours, at: '12:00'
every 24.hours, at: ['00:00', '12:00']
every 24.hours, at: '**:05'
every 24.hours, at: '00:00', tz: 'UTC'
every 5.seconds, at: '10:**'
every 1.week, at: 'Monday 12:30'
```

See the full set of options on the [Clockwork README](https://github.com/tomykaira/clockwork#event-parameters).

##### Job workflow

When a job kicks off, steps are run serially in the order they are specified. Each step is invoked with 2
arguments - the response of the step immediately preceding it, and a map of all responses so far.
The map is keyed by step name, which defaults to a plugin name if a plugin was used but a step name not specified.

Here's an example that shows how the response chain works:

``` ruby
job do
  every 5.minutes
  step 'one' do
    1
  end
  step 'two' do |response|
    5 + response
  end
  step 'add previous steps' do |response, step_responses|
    puts response # prints 5
    puts step_responses['one'] + step_responses['two'] # prints 6
  end
end
```

If a `step` returns false, subsequent steps **are not run**. Here's a simple example that illustrates this:

``` ruby
job 'lame job' do
  every 5.minutes
  step 'one' do
    false
  end
  step 'two' do
    # never called!
  end
end
```

This behavior is designed to make *conditional* alerting easy. Here's an example of a job that only sends an alert
for certain query responses:

``` ruby
job do

  every 1.minute

  keen do
    event_collection 'errors'
    analysis_type 'count'
    timeframe 'last_1_minute'
  end

  step 'notify only if there are errors' do |response|
    response > 0
  end

  twilio do |step_responses|
    to '+18005555555'
    body "There were #{step_responses['keen']} errors in the last minute!"
  end
end
```

In this example, the `twilio` step will only be ran if the `keen` step returned a count greater than 0.

#### Steps

Steps have the following attributes:

+ `name`: (optional) something that describes the step. Useful in logs, and is the key in the `step_responses` hash. Defaults to plugin name, then an auto-generated value.
+ `plugin`: (optional) if the step is backed by a plugin, it's the name of the plugin
+ `block`: A block that runs to configure the step (when a plugin is used), or run it.

Steps can be pure Ruby code, or in the case of a plugin calling into a DSL.

Steps have built-in support for ERB templating. This is useful for generating more complex emails and reports.

Here's an example that uses a template:

``` ruby
sendgrid do |response, step_responses|
  to 'josh+pushpop@keen.io'
  from 'pushpopapp+123@keen.io'
  subject 'Pingpong Daily Response Time Report'
  body template 'pingpong_report.html.erb', response, step_responses
  preview false
end
```

`template` is a function that renders a template in context of the step responses and returns a string.
The first argument is a template file name, located in the `templates` directory by default.
The second and third arguments are the response and step_responses respectively.
An optional fourth parameter can be used to change the path templates are looked for in.

Here's a very simple template:

``` erb
<h1>Daily Report</h1>
<p>We got <%= response %> new users today!</p>
```

### Recipes

Here are some ways to use Pushpop to do common tasks.

##### Error alerting with Pingpong

[Pingpong](https://github.com/keenlabs/pingpong.git) captures HTTP request/response data for remote URLs.
By pairing Pingpong with Pushpop, you can get custom alerts and reports about the web performance and
availability you're attempting to observe.

Here's a job that sends an SMS if any check had errors in the last minute.

``` ruby
job do

  every 1.minute

  keen do
    event_collection 'checks'
    analysis_type 'count'
    timeframe 'last_1_minute'
    filters [{
      property_name: "response.successful",
      operator: "eq",
      property_value: false
    }]
  end

  step 'notify only if there are errors' do |response|
    response > 0
  end

  twilio do |step_responses|
    to '+18005555555'
    body "There were #{step_responses['keen']} errors in the last minute!"
  end
end
```

##### Daily response time email report

See [examples/keen_sendgrid_job.rb](examples/keen-sendgrid_job.rb and the
[corresponding template](examples/templates/keen_sendgrid.html.erb).

### Plugin Documentation

All plugins are located at `lib/plugins`. They are loaded automatically.

##### Keen

The `keen` plugin gives you a DSL to specify Keen query parameters. When it runs, it
passes those parameters to the [keen gem](https://github.com/keenlabs/keen-gem), which
in turn runs the query against the Keen IO API.

Here's an example that shows most of the options you can specify:

``` ruby
job 'daily average response time by check for successful requests in april' do

  keen do
    event_collection  'checks'
    analysis_type     'average'
    target_property   'request.duration'
    group_by          'check.name'
    interval          'daily'
    timeframe         ({ start: '2014-04-01T00:00Z' })
    filters           [{ property_name: "response.successful",
                         operator: "eq",
                         property_value: true }]
  end

end
```

The `keen` plugin requires that the following environment variables are set: `KEEN_PROJECT_ID` and `KEEN_READ_KEY`.

A `steps` method is also supported for [funnels](https://keen.io/docs/data-analysis/funnels/),
as well as `analyses` for doing a [multi-analysis](https://keen.io/docs/data-analysis/multi-analysis/).

##### Sendgrid

The `sendgrid` plugin gives you a DSL to specify email recipient information, as well as the subject and body.

Here's an example:

``` ruby
job 'send an email' do

  sendgrid do
    to 'josh+pushpop@keen.io'
    from 'pushpopapp+123@keen.io'
    subject 'Hey, ho, Let's go!'
    body 'This page was intentionally left blank.'
    preview false
  end

end
```

The `sendgrid` plugin requires that the following environment variables are set: `SENDGRID_DOMAIN`, `SENDGRID_USERNAME`, and `SENDGRID_PASSWORD`.

The `preview` directive is optional and defaults to false. If you set it to true, the email contents will print out
to the console, but the email will not send.

The `body` method can take a string, or it can take the same parameters as `template`,
in which case it will render a template to create the body. For example:

``` ruby
body 'pingpong_report.html.erb', response, step_responses
```

##### Twilio

The `twilio` plugin gives you a DSL to specify SMS recipient information as well as the text itself.

Here's an example:

``` ruby
job 'send a text' do

  twilio do
    to '18005555555'
    body 'Breathe in through the nose, out through the mouth.'
  end

end
```

The `twilio` plugin requires that the following environment variables are set: `TWILIO_AUTH_TOKEN`, `TWILIO_SID`, and `TWILIO_FROM`.

### Creating plugins

Plugins are just subclasses of `Pushpop::Step`. Plugins should implement a run method, and
register themselves. Here's a simple plugin that stops job execution if the input into the step is 0:

``` ruby
module Pushpop
  class BreakIfZero < Step
    PLUGIN_NAME = 'break_if_zero'
    def run(last_response=nil, step_responses=nil)
      last_response == 0
    end
  end

  Pushpop::Job.register_plugin(BreakIfZero::PLUGIN_NAME, BreakIfZero)
end

# now in your job you can use the break_if_zero step

job do
  step do [0, 1].shuffle.first end
  break_if_zero
  step do puts 'made it through!' end
end
```

### Contributing

Issues and pull requests are welcome! Some ideas are to:

+ Add more plugins!
+ Add a web interface that lets you preview emails in the browser

Pushpop has a full set of specs (including plugins). Run them like this:

``` shell
$ bundle exec rake spec
```
