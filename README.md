##Stringer
[![Build Status](https://travis-ci.org/swanson/stringer.png)](https://travis-ci.org/swanson/stringer)
[![Code Climate](https://codeclimate.com/github/swanson/stringer.png)](https://codeclimate.com/github/swanson/stringer)
[![Coverage Status](https://coveralls.io/repos/swanson/stringer/badge.png?branch=master)](https://coveralls.io/r/swanson/stringer)

### A [work-in-progress] self-hosted, anti-social RSS reader.

Stringer has no external dependencies, no social recommendations/sharing, and no fancy machine learning algorithms. 

But it does have keyboard shortcuts (hit `?` from within the app) and was made with love!

When `BIG_FREE_READER` shuts down, your instance of Stringer will still be kicking.

![](screenshots/instructions.png)
![](screenshots/stories.png)
![](screenshots/feed.png)

The app is currently under active development, please try it out and report any issues you have.

# Installation

Stringer is a Ruby app based on Sinatra, ActiveRecord, PostgreSQL, Backbone.js and DelayedJob.

Instructions are provided for deploying to Heroku (runs fine on the free plan) but Stringer can be deployed anywhere that supports Ruby.

```sh
git clone git://github.com/swanson/stringer.git
cd stringer
heroku create
git push heroku master

heroku config:set SECRET_TOKEN=`openssl rand -hex 20`

heroku run rake db:migrate
heroku restart

heroku addons:add scheduler
heroku addons:open scheduler

Add an hourly task that runs `rake fetch_feeds`
```

Load the app and follow the instructions to import your feeds and start using the app.

## Updating the app

From the app's directory:

```sh
git pull
git push heroku master
heroku run rake db:migrate
heroku restart
```

# Niceties

You can run Stringer at `http://reader.yourdomain.com` using a CNAME.

If you are on Heroku:

`heroku domains:add reader.yourdomain.com`

Go to your registrar and add a CNAME:
```
Record: CNAME
Name: reader
Target: your-heroku-instance.herokuapp.com
```

Wait a few minutes for changes to propagate.

---

Stringer has been translated to [several other languages](config/locales). Your language can be set with the `LOCALE` environment variable.

To set your locale on Heroku, run `heroku config:set LOCALE=en`.

If you would like to translate Stringer to your preferred language, please use [LocaleApp](http://www.localeapp.com/projects/4637).

# Development

Run the tests with `rspec`.

In development, stringer uses `sqlite` - there are issues with locking if you run background jobs at the same time as queries are being made via the web app. If you run into these, consider using `pg` locally.

## Getting Started

To get started using Stringer locally simply run the following:

```sh
bundle install
rake db:migrate
foreman start
```

The application will be running on port `5000`

You can launch an interactive console (ala `rails c`) using `racksh`

# Acknowledgements
Most of the heavy-lifting is done by [`feedzirra`](https://github.com/pauldix/feedzirra) and [`feedbag`](https://github.com/dwillis/feedbag).

General sexiness courtesy of [`Twitter Bootstrap`](http://twitter.github.io/bootstrap/) and [`Flat UI`](http://designmodo.github.io/Flat-UI/).

# Contact
Matt Swanson, [mdswanson.com](http://mdswanson.com) [@_swanson](http://twitter.com/_swanson)

