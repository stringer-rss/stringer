Stringer on DigitalOcean
========================

Deploying into DigitalOcean using azk
------------------------

> You can find a detailed tutorial on deploying Stringer on DigitalOcean using azk here: https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-azk

After you run Stringer locally using [`Run Project` button](https://github.com/swanson/stringer#using-azk), deploying to [DigitalOcean](http://digitalocean.com/) is very simple.

First, be sure you have SSH keys configured in your machine. If you don't have it yet (or if you aren't sure about it), just follow steps 1 and 2 of [this tutorial](https://help.github.com/articles/generating-ssh-keys/).

Next, put your [personal access token](https://cloud.digitalocean.com/settings/applications) into a `.env` file:

```bash
$ cd path/to/the/project
$ echo "DEPLOY_API_TOKEN=<YOUR-PERSONAL-ACCESS-TOKEN>" >> .env
```

Then, just run the following:

```bash
$ azk deploy
```

Find instructions for further resources (mostly customizations) to deploy to DigitalOcean using `azk` [here](http://docs.azk.io/en/deploy/README.html).