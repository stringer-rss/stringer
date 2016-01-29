Stringer on OpenShift
========================

Deploying into OpenShift
------------------------

1. Creating new OpenShift Ruby 2.0 application with the Postgresql cartridge (command-line).

 ```sh
    rhc app create feeds ruby-2.0 postgresql-9.2
 ```

2. Pull the code from the Stringer Github repository.

 ```sh
	cd feeds
	git remote add upstream git://github.com/swanson/stringer.git
	git pull -s recursive -X theirs upstream master
 ```

3. To enable migrations for the application, a new action_hook is required. Add the file, .openshift/action_hooks/deploy,  with the below 3 lines into it.

 ```
	pushd ${OPENSHIFT_REPO_DIR} > /dev/null
	bundle exec rake db:migrate RACK_ENV="production"
	popd > /dev/null
 ```

4. Make sure that the file created above is executable on Unix-like systems.

 ```sh
    chmod +x .openshift/action_hooks/deploy
 ```

5. Set the SECRET_TOKEN as a rhc environment variable by generating it with the command below.

 ```sh
    rhc env set SECRET_TOKEN="`openssl rand -hex 20`"
 ```

6. Configuration of the database server is next. Open the file config/database.yml and add in the configuration for Production as shown below. OpenShift is able to use environment variables to push the information into the application.

 ```
	production:
		adapter: postgresql
		database: <%= ENV["OPENSHIFT_APP_NAME"] %>
		host: <%= ENV["OPENSHIFT_POSTGRESQL_DB_HOST"] %>
		port: <%= ENV["OPENSHIFT_POSTGRESQL_DB_PORT"] %>
		username: <%= ENV["OPENSHIFT_POSTGRESQL_DB_USERNAME"] %>
		password: <%= ENV["OPENSHIFT_POSTGRESQL_DB_PASSWORD"] %> 
 ```

7. Due to an older version of bundler being used in OpenShift (1.3.5), some changes need to be made in the Gemfile. 

	Remove the Ruby version specification from the Gemfile below (error reporting wrong Ruby version when deploying to OpenShift). 

 ```
	ruby '2.0.0'
 ```

	Then change the two gem dependencies below to use the hash rocket syntax for the "require" option.

 ```
	gem "coveralls", "~> 0.7", require: false
	gem "rubocop", "~> 0.35.1", require: false
	gem "sinatra-assetpack", "~> 0.3.1", require: "sinatra/assetpack"
 ```
	to
 ```
	gem "coveralls", "~> 0.7", :require => false
	gem "rubocop", "~> 0.35.1", :require => false
	gem "sinatra-assetpack", "~> 0.3.1", :require => "sinatra/assetpack"
 ```

8. Finally, once completed, all changes should be committed and pushed to OpenShift. Note that it might take a while when pushing to OpenShift.

 ```sh
	git add .
	git commit -m "Deployment of Stringer"
	git push origin
 ```

9. Check that you are able to access the website at the URL given, i.e. feeds-username.rhcloud.com. Then set your password, import your feeds and all good to go!


Adding Cronjob to Fetch Feeds
-----------------------------

After importing feeds, a cron job is needed on OpenShift to fetch feeds. 

1. Add a new cron cartridge for the cron job.

 ```sh
    rhc cartridge add cron -a feeds
 ```

2. Add a new executable file, .openshift/cron/hourly/fetch_feeds and put the below 4 lines into it. 

 ```
	./usr/bin/rhcsh
	pushd ${OPENSHIFT_REPO_DIR} > /dev/null
	bundle exec rake fetch_feeds RACK_ENV="production"
	popd > /dev/null
 ```

3. Make the file executable.

 ```sh
    chmod +x .openshift/cron/hourly/fetch_feeds
 ```

4. Push all changes to OpenShift.

 ```sh
	git add .
	git commit -m "Added Cronjob"
	git push origin
 ```

5. Done! The cron job should fetch feeds every hour.

Password Reset
--------------
In the event that you need to change your password, run the following commands
```
rhc ssh feeds
cd app-root/repo	
bundle exec rake change_password RACK_ENV="production"
```
