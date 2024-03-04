# frozen_string_literal: true

class AddPrecisionToTimestamps < ActiveRecord::Migration[7.1]
  SKIP_TABLES = [:schema_migrations, :ar_internal_metadata].freeze

  def up
    migrate_precision(precision: 6)
  end

  def down
    migrate_precision(precision: nil)
  end

  def migrate_precision(precision:)
    table_names = ActiveRecord::Base.connection.tables.map(&:to_sym)
    table_names.each do |table|
      next if SKIP_TABLES.include?(table)

      ActiveRecord::Base.connection.columns(table).each do |column|
        next unless datetime_column?(column)

        change_column(table, column.name, :datetime, precision:)
      end
    end
  end

  private

  def datetime_column?(column)
    column.sql_type_metadata.type == :datetime
  end
end
