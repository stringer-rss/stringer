# frozen_string_literal: true

RSpec.describe "removable resources" do
  def draw_routes(api_only: false, &)
    config = ActionDispatch::Routing::RouteSet::Config.new(nil, api_only, nil)
    route_set = ActionDispatch::Routing::RouteSet.new(config)
    route_set.draw(&)
    route_set.routes.map { |route| [route.verb, route.path.spec.to_s] }
  end

  def remove_route(path) = ["GET", "#{path}/remove(.:format)"]

  it "adds a remove route to resources by default" do
    routes = draw_routes { resources(:posts) }

    expect(routes).to include(remove_route("/posts/:id"))
  end

  it "adds a remove route to a singular resource by default" do
    routes = draw_routes { resource(:profile) }

    expect(routes).to include(remove_route("/profile"))
  end

  it "adds a remove route when listed in only" do
    routes = draw_routes { resources(:posts, only: [:remove, :destroy]) }

    expect(routes).to include(remove_route("/posts/:id"))
  end

  it "does not add a remove route when left out of only" do
    routes = draw_routes { resources(:posts, only: [:show, :destroy]) }

    expect(routes).not_to include(remove_route("/posts/:id"))
  end

  it "does not add a remove route when listed in except" do
    routes = draw_routes { resources(:posts, except: [:remove]) }

    expect(routes).not_to include(remove_route("/posts/:id"))
  end

  it "does not add a remove route to API-only resources" do
    routes = draw_routes(api_only: true) { resources(:posts) }

    expect(routes).not_to include(remove_route("/posts/:id"))
  end

  it "names the remove route helper after the resource" do
    route_set = ActionDispatch::Routing::RouteSet.new
    route_set.draw { resources(:posts) }

    expect(route_set.url_helpers.remove_post_path(1)).to eq("/posts/1/remove")
  end
end
