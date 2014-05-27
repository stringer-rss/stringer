class FeedFactory
  class FakeFeed < OpenStruct
    def as_fever_json
      {
        id: self.id,
        favicon_id: 0,
        title: self.name,
        url: self.url,
        site_url: self.url,
        is_spark: 0,
        last_updated_on_time: self.last_fetched.to_i
      }
    end
  end

  def self.build(params = {})
    FakeFeed.new(
      id: rand(100),
      group_id: params[:group_id] || rand(100),
      name: params[:name] || Faker::Name.name + " on Software",
      url: params[:url] || Faker::Internet.url,
      last_fetched: params[:last_fetched] || Time.now,
      stories: params[:stories] || [])
  end
end
