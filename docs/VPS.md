Install some dependencies
=========================

The first step is installing some essential dependencies from your VPS's package manager.

#### Ubuntu/Debian

    sudo apt-get install git libxml2-dev libxslt-dev libcurl4-openssl-dev libpq-dev build-essential postgresql libreadline-dev

#### CentOS/Fedora

    sudo yum install git libxml2-devel libxslt-devel curl-devel postgresql-devel make automake gcc gcc-c++ postgresql-server readline-devel openssl-devel

On CentOS after installing Postgres, I needed to run these commands, Fedora likely the same.

    service postgresql initdb && service postgresql start

#### Arch Linux

    pacman -S git postgresql base-devel libxml2 libxslt curl readline postgresql-libs

Here are some Arch specific instructions for setting up postgres

    systemd-tmpfiles --create postgresql.conf
    chown -c -R postgres:postgres /var/lib/postgres
    sudo su - postgres -c "initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'"
    systemctl start postgresql
    systemctl enable postgresql


Set up the database
===================

Create a postgresql user to own the database Stringer will use, you will need to create a password too, make a note of it.

    sudo -u postgres createuser -D -A -P stringer

Now create the database Stringer will use

    sudo -u postgres createdb -O stringer stringer_live

Create your stringer user
=========================

We will run stringer as it's own user for security, also we will be installing a specific version of ruby to stringer user's home directory, this saves us worrying whether the version of ruby and some dependencies provided by your distro are compatible with Stringer.

    sudo useradd stringer -m -s /bin/bash
    sudo su -l stringer

Always use -l switch when you switch user to your stringer user, without it your modified .bash_profile or .profile file will be ignored.

Install Ruby for your stringer user
===================================

We are going to use Rbenv to manage the version of Ruby you use.

    cd
    git clone git://github.com/sstephenson/rbenv.git .rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.bash_profile
    echo 'eval "$(rbenv init -)"' >> $HOME/.bash_profile
    git clone git://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build
    source ~/.bash_profile

    rbenv install 2.7.2
    rbenv local 2.7.2
    rbenv rehash

We also need to install bundler which will handle Stringer's dependencies

    gem install bundler
    rbenv rehash

We will also need foreman to run our app

    gem install foreman

Install Stringer and set it up
==============================

Grab Stringer from github

    git clone https://github.com/swanson/stringer.git
    cd stringer

Use bundler to grab and build Stringer's dependencies

    bundle install
    rbenv rehash

Stringer uses environment variables to configure the application. Edit these values to reflect your settings.

    echo 'export DATABASE_URL="postgres://stringer:EDIT_ME@localhost/stringer_live"' >> $HOME/.bash_profile
    echo 'export RACK_ENV="production"' >> $HOME/.bash_profile
    echo "export SECRET_TOKEN=`openssl rand -hex 20`" >> $HOME/.bash_profile
    source ~/.bash_profile

Tell stringer to run the database in production mode, using the `postgres` database you created earlier.

    cd $HOME/stringer
    rake db:migrate RACK_ENV=production

Run the application:

    foreman start

Set up a cron job to parse the rss feeds.

    crontab -e

add the lines

    SHELL=/bin/bash
    PATH=/home/stringer/.rbenv/bin:/bin/:/usr/bin:/usr/local/bin/:/usr/local/sbin
    */10 * * * *  source $HOME/.bash_profile; cd $HOME/stringer/; bundle exec rake fetch_feeds;

Manage Stringer With Systemd
============================

You may want to manage Stringer as a systemd service on distributions come with systemd.

As stringer user, export app service files with foreman:

    cd ~/stringer
    mkdir systemd-services
    foreman export systemd systemd-services -a stringer -u stringer

Logout stringer user, install systemd services:

    sudo cp -a ~stringer/stringer/systemd-services/* /etc/systemd/system

As stringer user, close existing Stringer instance:

    exit # exit racksh and app

Start app as a systemd service and make app run at startup

    sudo systemctl start stringer.target
    sudo systemctl enable stringer.target

Reverse Proxy With Nginx
========================

You may want to use nginx as reverse proxy server to add SSL/TLS for security
reason. Here is a sample configuration:

``` nginx
server {
    listen 80;
    # listen 443 ssl;
    # ssl_certificate ssl/fullchain.pem;
    # ssl_certificate_key ssl/privatekey.pem;
    # you can try to use Mozilla SSL Configuration Generator
    # to harden your TLS configuration
    # https://mozilla.github.io/server-side-tls/ssl-config-generator/
    server_name example.com;
    location / {
        proxy_pass http://127.0.0.1:1337/;
        proxy_set_header Host $host;
    }
}
```

Deploy Stringer With Passenger And Apache
=========================================

You may want to run Stringer with the existing Apache server. We need to install
*mod_passenger* and edit few files.

The installation of *mod_passenger* depends on VPS's system distribution release.
Offical installation guide is available at [Passenger Library](https://www.phusionpassenger.com/library/install/apache/install/oss/)

After validating the *mod_passenger* install, we will fetch dependencies again
to meet Passenger's default GEM_HOME set. As stringer user:

    cd ~/stringer
    bundle install --path vendor/bundle

Edit database.yml with correct database url:

    cd ~/stringer
    sed -i "s|url: .*|url: $DATABASE_URL|" config/database.yml

Add VirtualHost to your Apache installation, here's a sample configuration:

```bash
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /home/stringer/stringer/app/public

    PassengerEnabled On
    PassengerAppRoot /home/stringer/stringer
    PassengerRuby /home/stringer/.rbenv/shims/ruby
    # PassengerLogFile /dev/null # don't flow logs to apache error.log

    <Directory /home/stringer/stringer/app/public>
        Options FollowSymLinks
        Require all granted
        AllowOverride All
    </Directory>


    # you can harden your connection with https, don't forget
    # change to <VirtualHost *:443>
    # SSLCertificateFile /etc/path/to/example.com/fullchain.pem
    # SSLCertificateKeyFile /etc/path/to/example.com/privkey.pem
    # Include /etc/path/to/options-ssl-apache.conf
</VirtualHost>
```
