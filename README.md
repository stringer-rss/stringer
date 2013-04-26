A work-in-progress, self-hosted, anti-social RSS reader.

![](https://raw.github.com/swanson/stringer/master/screenshots/instructions.png)

![](https://raw.github.com/swanson/stringer/master/screenshots/feed.png)

The app is currently under active development, if you would like to try it out, please be aware that things may be breaking at a rapid pace.

# Installation

* Clone the repository
`git clone git://github.com/swanson/stringer.git`

* Deploy to Heroku
`heroku create`
`heroku addons:add scheduler`
`git push heroku master`

* Setup the database
`heroku run rake db:migrate`
`heroku restart` (needed for DelayedJob)

* Setup feed fetching
`heroku addons:open scheduler`
Add an hourly task that runs `rake fetch_feeds`

* Follow the app setup
`heroku open`

# Niceities

* Custom `reader.yourdomain.com`
`heroku domains:add reader.yourdomain.com`

Go to your registrar and add a CNAME:
Record: CNAME
Name: reader
Target: your-heroku-instance.herokuapp.com

Wait a few minutes for changes to progate.

* Avoid dyno idle
Single dyno Heroku apps idle after a period of inactivity.

You can setup a ping/availability service to prevent this.

# Development

Run the tests with `rspec`.

In development, stringer uses sqlite - there are issues with locking if you run background jobs at the same time as queries are being made via the web app. If you run into these, consider using postgres locally.

# License
MIT


It looks something like this at the moment:



![](https://raw.github.com/swanson/stringer/master/screenshots/rss-zero.png)

