# pushover

Send emails & notifications in response to analytics events.

Here are some ways to use pushover:

+ Send out a daily email of your metrics
+ Send an alerting email or SMS when a metric has changed
+ Fetch metrics at an interval to keep a cache fresh

Pushover contains plugins for [Keen IO](https://keen.io) and [Sendgrid](https://sendgrid.com) that make querying and emailing very easy.
That said, pushover is totally plugin-based, and adding support for other data sources and messaging plugins is encouraged!

### Usage

The core concepts of pushover are jobs and steps. Jobs run at regular intervals, and consist of one or more steps.
Jobs and steps are described in a `Pushfile`.

Here's a `Pushfile` that runs a Keen IO analysis every day at midnight, then sends an email with the results:

``` ruby
require 'pushover'

job do

  every 24.hours, at: '00:00'

  keen do
    event_collection 'signups'
    analysis_type 'count',
    timeframe 'last_24_hours'
  end

  sendgrid do |response|
    to 'team@keen.io'
    from 'pushover@keen.io'
    subject "There were #{response} Signups Today!"
    template 'signup_report.html.erb'
  end

end
```

When this job kicks off, the steps run synchronously, and in the order they were defined.
First, the `keen` step runs using the `keen` plugin.
The result of the `keen` step is passed the `sendgrid` step. From there, the `sendgrid` plugin
will send an email with the result of the query.

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

the `jobs:test` rake task runs each job just once, so you can see what it'll do. another rake task, `jobs:run`,
will run the jobs at the intervals you've defined.

``` shell
$ bundle exec rake jobs:run
```

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

For example, if you have a job configured to run `every 10.minutes`, this process sleep for 10 minutes, wake up
and run your job, then repeat that process indefinitely.
Note: This process will run indefinitely until it is killed. This is the process to run when you deploy.

### Deployment

Pushover uses Clockwork to schedule jobs. Clockwork creates a lightweight, long-running
Ruby process that does work at configurable intervals. It doesn't install anything into cron,
and there's no confusing cron syntax required. It will run anywhere a Ruby app can, Heroku included.

Here's how to deploy to Heroku.

First, create a new Heroku app. Make sure you're within your `pushover` project directory.

``` shelll
$ heroku create
```

Now, upload configuration to your Heroku app. If you're using Keen and Sendgrid, you'll need to specify
the environment variables they expect. An easy way to upload Heroku configs is using the heroku:config plugin,
which uses a .env file in the project directory.

``` shell
$ echo 'KEEN_PROJECT_ID=<my-project-id>' >> .env
$ echo 'KEEN_READ_KEY=<my-read-key>' >> .env
$ echo 'SENDGRID_USERNAME=<my-username>' >> .env
$ echo 'SENDGRID_PASSWORD=<my-password>' >> .env
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
