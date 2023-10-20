# frozen_string_literal: true

module ActiveRecord
  module DataClassification
    class ModelReflection
      attr_reader :server_type, :table_name, :model_name

      def initialize(table_name, models)
        @models = models
        @model  = @models.find { |m| m.try(:base_class) == m } || @models.first

        @server_type = find_server_type(table_name)

        @model_name = @model.name
        @table_name = table_name
      end

      def columns
        connection.columns(table_name).map do |column|
          column_spec = @model.try(:field_specs)&.[](column.name)
          Column.new(
            column.name,
            column.sql_type,
            sensitivity_friendly(@models, column_spec&.data_security),
            sensitivity_source(@models, column_spec&.data_security),
            anonymization_type || column_spec&.anonymize_using,
            @models
          )
        end
      end

      private

      def anonymization_type
        if sensitivity_friendly(@models, nil) == "Confidential"
          "Truncated"
        end
      end

      def sensitivity(models, field_sensitivity)
        if (model_sensitivity = models.map_and_find { |m| m.try(:data_security) })
          model_sensitivity
        elsif field_sensitivity
          field_sensitivity
        end
      end

      def sensitivity_friendly(models, field_sensitivity)
        sensitivity(models, field_sensitivity)&.to_s
      end

      def sensitivity_source(models, field_sensitivity)
        if (model = models.find { |m| m.try(:data_security) })
          model.name
        elsif field_sensitivity
          "Field"
        end
      end

      def find_server_type(table_name)
        case table_name
        when /number_attributions_partitioned/
          "attr"
        when  /\Acf_.*/
          "shard"
        else
          "common"
        end
      end

      def connection
        ActiveRecord::Base.connection
      end
    end
  end
end

if defined?(Aggregate)
  require_relative 'aggregate/extension'
  ActiveRecord::DataClassification::ModelReflection.include(ActiveRecord::DataClassification::Aggregate::Extension)
end
