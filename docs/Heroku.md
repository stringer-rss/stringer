```sh
git clone git://github.com/swanson/stringer.git
cd stringer
heroku create
git push heroku master

heroku config:set APP_URL=`heroku apps:info --shell | grep web-url | cut -d= -f2`
heroku config:set SECRET_TOKEN=`openssl rand -hex 20`

heroku run rake db:migrate
heroku restart

heroku addons:add scheduler
heroku addons:open scheduler
```

Add an hourly task that runs `rake lazy_fetch` (if you are not on Heroku you may want `rake fetch_feeds` instead).

Load the app and follow the instructions to import your feeds and start using the app.

See the "Niceties" section of the README for a few more tips and tricks for getting the most out of Stringer on Heroku.

## Updating the app

From the app's directory:

```sh
git pull
git push heroku master
heroku run rake db:migrate
heroku restart
```

## Password Reset

In the event that you need to change your password, run `heroku run rake change_password` from the app folder.
