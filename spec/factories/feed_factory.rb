class FeedFactory
  class FakeFeed < OpenStruct; end;

  def self.build(params = {})
    FakeFeed.new(
      name: params[:name] || Faker::Name.name + " on Software",
      url: params[:url] || Faker::Internet.url,
      last_fetched: params[:last_fetched] || Time.now,
      stories: params[:stories] || [])
  end
end