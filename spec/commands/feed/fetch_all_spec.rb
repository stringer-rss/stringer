# frozen_string_literal: true

RSpec.describe Feed::FetchAll do
  def stub_pool
    pool = instance_double(Thread::Pool)
    expect(Thread).to receive(:pool).and_return(pool)
    expect(pool).to receive(:process).at_least(:once).and_yield
    expect(pool).to receive(:shutdown)
  end

  it "calls Feed::FetchOne for every feed" do
    stub_pool
    feed1, feed2 = create_pair(:feed)

    expect { described_class.call }
      .to invoke(:call).on(Feed::FetchOne).with(feed1)
      .and invoke(:call).on(Feed::FetchOne).with(feed2)
  end
end
