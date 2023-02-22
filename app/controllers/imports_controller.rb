# frozen_string_literal: true

class ImportsController < ApplicationController
  def new; end

  def create
    ImportFromOpml.call(params["opml_file"].read, user: current_user)

    redirect_to("/setup/tutorial")
  end
end
