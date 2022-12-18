# frozen_string_literal: true

class ImportsController < ApplicationController
  def new; end

  def create
    ImportFromOpml.import(params["opml_file"].read)

    redirect_to("/setup/tutorial")
  end
end
