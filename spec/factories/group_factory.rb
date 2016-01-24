class GroupFactory
  class FakeGroup < OpenStruct
    def as_fever_json
      {
        id: id,
        title: name
      }
    end
  end

  def self.build(params = {})
    FakeGroup.new(
      id: rand(100),
      name: params[:name] || Faker::Name.name + " group")
  end
end
