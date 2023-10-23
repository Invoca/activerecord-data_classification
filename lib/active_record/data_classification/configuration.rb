# frozen_string_literal: true

module ActiveRecord
  module DataClassification
    class ConfigurationError < StandardError; end

    class Configuration
      attr_accessor :default_classification,
                    :ignored_tables,
                    :confidential_class_names,
                    :excluded_table_patterns

      attr_reader :load_models_block,
                  :table_name_transformer_block

      def initialize
        @default_classification       = :Private
        @load_models_block            = -> { }
        @table_name_transformer_block = ->(table_name) { table_name }
        @confidential_class_names     = []
        @excluded_table_patterns      = []
        @ignored_tables              = [
          "schema_migrations",
          "ar_internal_metadata",
        ]
      end

      def load_models(&block)
        @load_models_block = block
      end

      def transform_table_name(&block)
        @table_name_transformer_block = block
      end
    end
  end
end
