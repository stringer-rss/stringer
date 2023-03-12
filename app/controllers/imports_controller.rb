# frozen_string_literal: true

class ImportsController < ApplicationController
  def new
    authorization.skip
  end

  def create
    authorization.skip
    Feed::ImportFromOpml.call(params["opml_file"].read, user: current_user)

    redirect_to("/setup/tutorial")
  end
end
