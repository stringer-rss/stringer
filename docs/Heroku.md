```sh
git clone git@github.com:stringer-rss/stringer.git
cd stringer
heroku create
git push heroku main

heroku config:set APP_URL=`heroku apps:info --shell | grep web_url | cut -d= -f2`
heroku config:set SECRET_TOKEN=`openssl rand -hex 20`

heroku run rake db:migrate
heroku restart

heroku addons:create scheduler
heroku addons:open scheduler
```

Add an hourly task that runs `rake lazy_fetch` (if you are not on Heroku you may want `rake fetch_feeds` instead).

Load the app and follow the instructions to import your feeds and start using the app.

See the "Niceties" section of the README for a few more tips and tricks for getting the most out of Stringer on Heroku.

## Updating the app

From the app's directory:

```sh
git pull
git push heroku main
heroku run rake db:migrate
heroku restart
```
