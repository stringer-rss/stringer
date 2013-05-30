require "rack-superfeedr"
require "date"
require "ostruct"
require "json"

require_relative "../repositories/feed_repository"
require_relative "../repositories/story_repository"
require_relative "../repositories/user_repository"

class Stringer < Sinatra::Base

	begin

		ENV["SUPERFEEDR_HOST"] = "localhost"
		ENV["SUPERFEEDR_USERNAME"] = "demo"
	   	ENV["SUPERFEEDR_PASSWORD"] = "demo"

		user = UserRepository.get
		unless user.superfeedr_host.nil? && user.superfeedr_username.nil? && user.superfeedr_password.nil?
			ENV["SUPERFEEDR_HOST"] = user.superfeedr_host
			ENV["SUPERFEEDR_USERNAME"] = user.superfeedr_username
	   		ENV["SUPERFEEDR_PASSWORD"] = user.superfeedr_password
	   	end

		superfeedr_config =  {
	      :host     => ENV["SUPERFEEDR_HOST"],
	      :login    => ENV["SUPERFEEDR_USERNAME"],
	      :password => ENV["SUPERFEEDR_PASSWORD"],
	      :format => "json", 
	      :async => false
	    }

		use Rack::Superfeedr, superfeedr_config do |superfeedr|
		   	set :superfeedr, superfeedr

		   	superfeedr.on_notification do |notification|
	    		href = notification["standardLinks"]["self"][0]["href"]

	    		feed = FeedRepository.fetch_by_url(href)

	    		unless feed.nil?

	    			notification["items"].each do |e|

	    				old_story = StoryRepository.fetch_by_url(e["permalinkUrl"])

	    				if old_story.nil?

				    		story = OpenStruct.new e
							story.published = Time.at(e["published"].to_i).to_datetime.to_s
							story.url = e["permalinkUrl"]

							story = StoryRepository.add(story, feed)

							settings.stories << story.to_json
						end
					end
				end
	    	end
		end

	rescue Exception => msg  
		puts msg
	end	
end