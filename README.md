# Pushover

Send emails & notifications in response to analytics events.

Here are some ways to use pushover:

+ Send a daily metrics email
+ Send an email or SMS alert when a metric has changed
+ Fetch metrics at an interval to keep a cache fresh

Pushover currently ships with plugins for [Keen IO](https://keen.io/), [Twilio](https://twilio.com/), and [Sendgrid](https://sendgrid.com/).
Pushover is entirely plugin-based, and our goal is to add support for many more data sources and messaging systems. Pull requests welcome!

Protip: Pushover works great with [Pingpong](https://github.com/keenlabs/pingpong.git). (Pingpong lets you ping URLs and record response information as Keen events.)
Specifically, Pushover makes it easy to get custom alerts when Pingpong checks fail.

### Usage

The core concepts of Pushover are jobs and steps. Jobs run at regular intervals, and consist of one or more steps that run in sequence. Jobs and steps are described in a `Pushfile`.

Here's a `Pushfile` that runs a Keen IO analysis every day at midnight, then sends an email with the results:

``` ruby
require 'pushover'

job do

  every 24.hours, at: '00:00'

  keen do
    event_collection 'pageviews'
    analysis_type 'count'
    timeframe 'last_24_hours'
  end

  twilio do |response|
    to '+18005555555'
    body "There were #{response} Pageviews Today!"
  end

end
```

In the example above, the `keen` step runs first and does a count of `pageviews` over the last 24 hours.
The number of `pageviews` is passed into the `twilio` step, which sends an SMS to the provided phone number.

### Setup

Setting up your own Pushover instance is very easy.

First, clone or fork this repository, then install dependencies:

``` shell
$ git clone git@github.com:keenlabs/pushover.git
$ cd pushover
$ bundle install
```

The repository comes with a very simple `Pushfile` located in the project's root. This `Pushfile` is the
default for rake tasks. Try a rake task now:

``` shell
$ bundle exec rake jobs:test
```

The `jobs:test` rake task runs each job just once, so you can see what it'll do. Another rake task, `jobs:run`,
will run the jobs at the intervals you've defined.

``` shell
$ bundle exec rake jobs:run
```

Pushover uses [Clockwork](https://github.com/tomykaira/clockwork) to schedule jobs. Clockwork creates a lightweight, long-running Ruby process that does work at configurable intervals. It doesn't install anything into cron,
and there's no confusing cron syntax required. It will run anywhere a Ruby app can, Heroku included.

This rake task starts a Clockwork scheduler that will run indefinitely until it is killed. It runs each job you have defined at the times specified in the Pushfile.

You can also run rake tasks using a different Pushfile inside the project folder. Just add an argument to the rake task.

``` shell
$ bundle exec rake jobs:run[examples/Pushfile-Keen]
```

The default `Pushfile` isn't very interesting. You should change it to add the tasks you want to run. If you change it,
make sure to commit.

``` shell
$ git add Pushfile
$ git commit -m 'Added my jobs'
```

### Deployment

Here's how to deploy to Heroku.

First, create a new Heroku app. Make sure you're within your `pushover` project directory.

``` shelll
$ heroku create
```

Now, upload configuration to your Heroku app. If you're using Keen and Sendgrid, you'll need to specify
the environment variables they expect. An easy way to upload Heroku configs is using the heroku:config plugin,
which uses a .env file in the project directory.

``` shell
$ echo 'KEEN_PROJECT_ID=<my-project-id>'   >> .env
$ echo 'KEEN_READ_KEY=<my-read-key>'       >> .env
$ echo 'SENDGRID_USERNAME=<my-username>'   >> .env
$ echo 'SENDGRID_PASSWORD=<my-password>'   >> .env
$ echo 'SENDGRID_DOMAIN=heroku.com'        >> .env
$ heroku config:push
```

Now push to Heroku:

```
$ git push heroku master
```

Lastly, make sure you have the right processes running. Pushover uses 1 worker (see the `Procfile`).

``` shell
$ heroku scale worker=1
```

Your Pushover should be up and running. Tail the Heroku logs to see your jobs run:

``` shell
$ heroku logs --tail
```

### How steps work

Steps and jobs are the heart of the Pushover DSL (domain-specific language). A `Pushfile` contains one or more jobs,
and jobs contain one or more steps.

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

This behavior is the backbone of how *conditional* alerting works. Here's an example of conditional alerting:

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

### Recipes

Here are some ways to use Pushover to do common tasks.

##### Use with Pingpong

[Pingpong](https://github.com/keenlabs/pingpong.git) captures HTTP request/response data for remote URLs.
By pairing Pingpong with Pushover, you can get custom alerts and reports about the web performance and
availability you're attempting to observe.

Here's a `Pushfile` recipe that sends an SMS if any check had errors in the last minute.

``` ruby
job do

  every 1.minute

  keen do
    event_collection 'checks'
    analysis_type 'count'
    timeframe 'last_1_minute'
    filters [{
      property_name: "response.status",
      operator: "lte",
      property_value: 400
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

### Creating plugins

Coming soon!

