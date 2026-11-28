These steps set up Stringer on a Linux server. They were tested on Ubuntu
24.04, Fedora, CentOS Stream 10 and Arch Linux. If something is missing on
your system, please open an issue or pull request.

Install some dependencies
=========================

First install the packages needed to build Ruby and Stringer's gems, plus
PostgreSQL. (mise, used below, downloads a prebuilt Ruby when it can; these
packages let it build Ruby from source when it can't.)

#### Ubuntu/Debian

    sudo apt-get update
    sudo apt-get install git curl build-essential libssl-dev libyaml-dev \
      zlib1g-dev libffi-dev libreadline-dev libpq-dev postgresql

#### CentOS/Fedora

On CentOS, first turn on the CRB repository, which has `libyaml-devel`:

    sudo dnf install dnf-plugins-core
    sudo dnf config-manager --set-enabled crb

Then, on both CentOS and Fedora:

    sudo dnf install git curl gcc gcc-c++ make openssl openssl-devel libyaml-devel \
      zlib-devel libffi-devel readline-devel libpq-devel libatomic \
      postgresql-server postgresql-contrib

Set up Postgres and start it. The `PGSETUP_INITDB_OPTIONS` setting lets
Stringer log in with a password; without it, Postgres rejects the login.

    sudo PGSETUP_INITDB_OPTIONS="--auth-host=scram-sha-256" postgresql-setup --initdb
    sudo systemctl enable --now postgresql

#### Arch Linux

    sudo pacman -S git curl base-devel openssl libyaml zlib libffi readline \
      postgresql

Set up Postgres and start it:

    sudo -u postgres initdb --locale en_US.UTF-8 -E UTF8 \
      --auth-local=peer --auth-host=scram-sha-256 -D /var/lib/postgres/data
    sudo systemctl enable --now postgresql

Set up the database
===================

Create a Postgres user to own Stringer's database. You will be asked for a
password; make a note of it.

    sudo -u postgres createuser -P stringer

Now create the database:

    sudo -u postgres createdb -O stringer stringer_live

Create your stringer user
=========================

Stringer runs as its own user for security. Ruby and Node are installed in
this user's home directory, so they don't depend on the versions your
distribution ships.

    sudo useradd stringer -m -s /bin/bash
    sudo su -l stringer

Always use the `-l` flag when you switch to the stringer user. Without it,
your `.bash_profile` is ignored.

Install Stringer
================

Grab Stringer from GitHub:

    git clone https://github.com/stringer-rss/stringer.git
    cd stringer

Install Ruby, Node and pnpm
===========================

We use [mise](https://mise.jdx.dev) to install the Ruby, Node and pnpm versions
listed in Stringer's `.tool-versions` file.

    curl https://mise.run | sh
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bash_profile
    echo 'export RAILS_ENV=production' >> ~/.bash_profile
    source ~/.bash_profile

    cd ~/stringer
    mise install ruby node pnpm

`.tool-versions` also lists Postgres, which is only used for development, so
we name the tools to install rather than running a bare `mise install`.

Set up Stringer
===============

Stringer reads its settings from a `.env` file in its directory. Create one,
replacing `EDIT_ME` with the database password you chose earlier:

    cd ~/stringer
    cat > .env <<EOF
    DATABASE_URL=postgres://stringer:EDIT_ME@localhost/stringer_live
    SECRET_KEY_BASE=$(openssl rand -hex 64)
    ENCRYPTION_PRIMARY_KEY=$(openssl rand -hex 64)
    ENCRYPTION_DETERMINISTIC_KEY=$(openssl rand -hex 64)
    ENCRYPTION_KEY_DERIVATION_SALT=$(openssl rand -hex 64)
    EOF
    chmod 600 .env

Install Stringer's gems, build its assets and set up the database:

    bundle config set --local deployment true
    bundle config set --local without development:test
    bundle install
    bundle exec rails assets:precompile
    bundle exec rails db:migrate

Check that it starts:

    bundle exec puma -C config/puma.rb

You should see `Listening on http://0.0.0.0:3000`. Press `Ctrl-C` to stop it.

Stringer only works over HTTPS in production: plain HTTP requests are
redirected to `https://`. Put a reverse proxy with an SSL certificate in front
of it, as shown in the nginx section below, before opening it in a browser.

Fetch feeds on a schedule
=========================

Feeds are fetched by a cron job. As the stringer user, run:

    crontab -e

and add these lines:

    */10 * * * * bash -lc 'cd ~/stringer && bundle exec rake fetch_feeds'
    0 0 * * * bash -lc 'cd ~/stringer && bundle exec rake cleanup_old_stories'

The first fetches feeds every 10 minutes. The second removes read, unstarred
stories older than 30 days once a day.

Run Stringer with systemd
=========================

To start Stringer when the server boots, run it as a systemd service. Log out
of the stringer user (`exit`) and create
`/etc/systemd/system/stringer.service`:

``` ini
[Unit]
Description=Stringer
After=network.target postgresql.service

[Service]
Type=simple
User=stringer
WorkingDirectory=/home/stringer/stringer
Environment=RAILS_ENV=production
ExecStart=/home/stringer/.local/bin/mise exec -- bundle exec puma -C config/puma.rb
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Then start it and make it run at boot:

    sudo systemctl daemon-reload
    sudo systemctl enable --now stringer

Background jobs run inside the same process, so this is the only service you
need.

Updating Stringer
=================

As the stringer user:

    cd ~/stringer
    git pull
    mise install ruby node pnpm
    bundle install
    bundle exec rails assets:precompile
    bundle exec rails db:migrate

Then restart the service with `sudo systemctl restart stringer`.

Reverse Proxy With Nginx
========================

Stringer needs HTTPS, so put nginx in front of it with an SSL certificate (for
example a free one from [Let's Encrypt](https://letsencrypt.org/)). Here is a
sample configuration:

``` nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    ssl_certificate /etc/path/to/example.com/fullchain.pem;
    ssl_certificate_key /etc/path/to/example.com/privkey.pem;
    # you can use the Mozilla SSL Configuration Generator
    # to harden your TLS configuration
    # https://ssl-config.mozilla.org/
    server_name example.com;
    location / {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Deploy Stringer With Passenger And Apache
=========================================

You may want to run Stringer with an existing Apache server instead of the
systemd service above. You will need to install *mod_passenger*.

How to install *mod_passenger* depends on your distribution. The official
installation guide is in the
[Passenger Library](https://www.phusionpassenger.com/library/install/apache/install/oss/).

Passenger needs the full path to Ruby. As the stringer user, find it with:

    cd ~/stringer
    mise which ruby

Add a VirtualHost to your Apache configuration, using that path for
`PassengerRuby`. Here's a sample:

```apache
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /home/stringer/stringer/public

    PassengerEnabled On
    PassengerAppRoot /home/stringer/stringer
    PassengerAppEnv production
    PassengerRuby /home/stringer/.local/share/mise/installs/ruby/VERSION/bin/ruby
    # PassengerLogFile /dev/null # don't flow logs to apache error.log

    <Directory /home/stringer/stringer/public>
        Options FollowSymLinks
        Require all granted
        AllowOverride All
    </Directory>

    # Stringer needs HTTPS: use <VirtualHost *:443> and set your certificate
    # SSLEngine on
    # SSLCertificateFile /etc/path/to/example.com/fullchain.pem
    # SSLCertificateKeyFile /etc/path/to/example.com/privkey.pem
    # Include /etc/path/to/options-ssl-apache.conf
</VirtualHost>
```
