# frozen_string_literal: true

module ActiveRecord
  module DataClassification
    module TableSpace
      class << self
        def all_tables
          @all_tables ||= connection.select_rows("select distinct(TABLE_NAME) from information_schema.columns where TABLE_SCHEMA='#{schema}'").flatten
        end

        def connection
          ActiveRecord::Base.connection
        end

        def schema
          connection.config[:database]
        end
      end
    end
  end
end
