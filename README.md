##Stringer
[![Build Status](https://travis-ci.org/swanson/stringer.png)](https://travis-ci.org/swanson/stringer)
[![Code Climate](https://codeclimate.com/github/swanson/stringer.png)](https://codeclimate.com/github/swanson/stringer)
### A [work-in-progress] self-hosted, anti-social RSS reader.

Stringer has no external dependencies, no social recommendations/sharing, and no fancy machine learning algorithms. 

When `BIG_FREE_READER` shuts down, your instance of Stringer will still be kicking.

![](https://raw.github.com/swanson/stringer/master/screenshots/instructions.png)

![](https://raw.github.com/swanson/stringer/master/screenshots/feed.png)

The app is currently under active development, please try it out and report any issues you have.

# Installation

Stringer is a Ruby app based on Sinatra, ActiveRecord, PostgreSQL, and DelayedJob.

Instructions are provided for deploying to Heroku (runs fine on the free plan) but Stringer can be deployed anywhere that supports Ruby.

```
git clone git://github.com/swanson/stringer.git
heroku create
git push heroku master

heroku run rake db:migrate
heroku restart #needed for DelayedJob/unicorn setup

heroku addons:add scheduler
heroku addons:open scheduler

Add an hourly task that runs `rake fetch_feeds`
```

Load the app and follow the instructions to import your feeds and start using the app.


# Niceities

You can run Stringer at `http://reader.yourdomain.com` using a CNAME.

If you are on Heroku:

`heroku domains:add reader.yourdomain.com`

Go to your registrar and add a CNAME:
Record: CNAME
Name: reader
Target: your-heroku-instance.herokuapp.com

Wait a few minutes for changes to progate.

# Development

Run the tests with `rspec`.

In development, stringer uses `sqlite` - there are issues with locking if you run background jobs at the same time as queries are being made via the web app. If you run into these, consider using `pg` locally.

# Acknowledgements
Most of the heavy-lifting is done by [`feedzirra`](https://github.com/pauldix/feedzirra) and [`feedbag`](https://github.com/dwillis/feedbag).

General sexiness courtesy of [`Twitter Bootstrap`](http://twitter.github.io/bootstrap/) and [`Flat UI`](http://designmodo.github.io/Flat-UI/).

# Contact
Matt Swanson, [mdswanson.com](http://mdswanson.com) [@_swanson](http://twitter.com/_swanson)
