# frozen_string_literal: true

# No-op: good_jobs and related tables were already created by this app's own
# earlier GoodJob migrations (see db/migrate/20230305010750_create_good_jobs.rb
# onward). This migration came from the template's initial GoodJob install and
# would otherwise try to recreate tables that already exist.
class CreateGoodJobs < ActiveRecord::Migration[8.1]
  def change; end
end
