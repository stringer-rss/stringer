# frozen_string_literal: true

module FeverAPI::ReadLinks
  def self.call(params)
    if params.key?(:links)
      { links: [] }
    else
      {}
    end
  end
end
