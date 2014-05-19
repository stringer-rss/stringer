Install some dependencies
=========================

The first step is installing some essential dependencies from your VPS's package manager.

#### Ubuntu/Debian

    sudo apt-get install git libxml2-dev libxslt-dev libcurl4-openssl-dev libpq-dev libsqlite3-dev build-essential postgresql libreadline-dev

#### CentOS/Fedora

    sudo yum install git libxml2-devel libxslt-devel curl-devel postgresql-devel sqlite-devel  make automake gcc gcc-c++ postgresql-server readline-devel openssl-devel

On CentOS after installing Postgres, I needed to run these commands, Fedora likely the same.

    service postgresql initdb && service postgresql start
    
#### Arch Linux

    pacman -S git postgresql base-devel libxml2 libxslt curl sqlite readline postgresql-libs
    
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

    useradd stringer -m -s /bin/bash
    su -l stringer

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

    rbenv install 2.0.0-p0
    rbenv local 2.0.0-p0
    rbenv rehash

We also need to install bundler which will handle Stringer's dependencies

    gem install bundler
    rbenv rehash

Install Stringer and set it up
==============================

Grab Stringer from github

    git clone https://github.com/swanson/stringer.git
    cd stringer

Use bundler to grab and build Stringer's dependencies

    bundle install
    rbenv rehash

Stringer uses environment variables to determine information about your database, edit these values to reflect your database and the password you chose earlier

    echo 'export STRINGER_DATABASE="stringer_live"' >> $HOME/.bash_profile
    echo 'export STRINGER_DATABASE_USERNAME="stringer"' >> $HOME/.bash_profile
    echo 'export STRINGER_DATABASE_PASSWORD="EDIT_ME"' >> $HOME/.bash_profile
    echo 'export RACK_ENV="production"' >> $HOME/.bash_profile
    echo "export SECRET_TOKEN=`openssl rand -hex 20`" >> $HOME/.bash_profile
    source ~/.bash_profile
    
Tell stringer to run the database in production mode, using the postgres database you created earlier.

    cd $HOME/stringer
    rake db:migrate RACK_ENV=production

Run the application:

    bundle exec foreman start

Set up a cron job to parse the rss feeds. 

    crontab -e

add the lines

    SHELL=/bin/bash
    PATH=/home/stringer/.rbenv/bin:/bin/:/usr/bin:/usr/local/bin/:/usr/local/sbin
    */10 * * * *  source $HOME/.bash_profile; cd $HOME/stringer/; bundle exec rake fetch_feeds;

