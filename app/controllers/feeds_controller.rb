# frozen_string_literal: true

class FeedsController < ApplicationController
  def index
    @feeds = FeedRepository.list
  end
end
