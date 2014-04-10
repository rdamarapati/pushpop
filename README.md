# pushover

Send emails & notifications in response to analytics events.

Here are some ways to use pushover:

+ Send a daily metrics email
+ Send an email or SMS alert when a metric has changed
+ Fetch metrics at an interval to keep a cache fresh

Pushover currently contains plugins for [Keen IO](https://keen.io/), [Twilio](https://twilio.com/), and [Sendgrid](https://sendgrid.com/) that make grabbing data and sending messages easy.

Pushover is entirely plugin-based, and adding support for other data sources and messaging plugins is encouraged!

### Usage

The core concepts of pushover are jobs and steps. Jobs run at regular intervals, and consist of one or more steps that run in sequence. Jobs and steps are described in a `Pushfile`.

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

  sendgrid do |response|
    to 'team@keen.io'
    from 'pushover@keen.io'
    subject "There were #{response} Pageviews Today!"
    body 'pageview_report.html.erb'
  end

  twilio do |_, step_responses|
    to '+18005555555'
    body "There were #{step_responses['keen']} Pageviews Today!"
  end

end
```

Each step runs in the order it was defined.

First, the `keen` step runs and does a count of pageviews over the last 24 hours.
The number of pageviews is passed the `sendgrid` step. The `sendgrid` step
sends an email with the number of pageviews in the subject.
Lastly, the `twilio` step sends an SMS to a given phone number.

Each step is invoked with 2 arguments - the response of the last step and a map of all responses so far. The map is keyed by step name, which defaults to the plugin name. In this example, `step_responses['keen']` holds the count that resulted from the `keen` step.

### Setup

Setting up your own pushover instance is very easy.

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

Your pushover should be up and running. Tail the Heroku logs to see your jobs run:

``` shell
$ heroku logs --tail
```

### Recipes

Here are some ways to use pushover to do common tasks.

TO BE CONTINUED!
