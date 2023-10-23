# frozen_string_literal: true

module ActiveRecord
  module DataClassification
    module Aggregate
      module Extension
        extend ActiveSupport::Concern

        AGGREGATE_BUILTINS =
          ::Aggregate::AttributeHandler::BUILTIN_TYPES
            .invert
            .merge(::Aggregate::Attribute::ForeignKey => "foreign_key").freeze

        # rubocop:disable Metrics/BlockLength
        included do
          alias_method :columns_without_aggregates, :columns

          def columns
            agg_columns = if (storage_field = @model.try(:aggregate_storage_field))
                            aggregate_columns(@model, "#{storage_field}->\"$.", @models)
                          else
                            []
                          end

            [*columns_without_aggregates, *agg_columns].flatten.compact
          end

          private

          def aggregate_columns(_klass, prefix, all_models)
            aggregate_models_by_field = {}
            aggregate_handlers_by_field = {}

            all_models.each do |model|
              model.aggregated_attribute_handlers.map do |key, handler|
                aggregate_models_by_field[key] ||= []
                aggregate_models_by_field[key] << model

                aggregate_handlers_by_field[key] ||= handler
              end
            end

            aggregate_models_by_field.map do |field, models|
              columns_for_aggregate_attribute(aggregate_handlers_by_field[field], field, models, prefix)
            end
          end

          def nested_aggregate_columns(klass, prefix, models)
            klass.aggregated_attribute_handlers.map do |field, handler|
              columns_for_aggregate_attribute(handler, field, models + [klass], prefix)
            end
          end

          def aggregate_type_name(_field, handler)
            AGGREGATE_BUILTINS[handler.class] || handler.class.name
          end

          def columns_for_aggregate_attribute(handler, key, models, prefix)
            case handler
            when *AGGREGATE_BUILTINS.keys
              Column.new(
                "#{prefix}#{key}\"", AGGREGATE_BUILTINS[handler.class],
                sensitivity_friendly(models, nil), sensitivity_source(models, nil), anonymization_type, models
              )
            when ::Aggregate::Attribute::List
              columns_for_aggregate_has_many(handler, key, models, prefix)
            when ::Aggregate::Attribute::NestedAggregate
              nested_aggregate_columns(handler.class_name.constantize, "#{prefix}#{key}.", models)
            when ::Aggregate::Attribute::SchemaVersion
              Column.new(
                "#{prefix}schema_version\"", "schema_version",
                sensitivity_friendly(models, nil), sensitivity_source(models, nil), anonymization_type, models
              )
            else
              raise "Unexpected handler #{handler.inspect}"
            end
          end

          def columns_for_aggregate_has_many(handler, key, models, prefix)
            case handler.element_helper
            when *AGGREGATE_BUILTINS.keys
              Column.new(
                "#{prefix}#{key}\"",
                "list of #{AGGREGATE_BUILTINS[handler.element_helper.class]}",
                sensitivity_friendly(models, nil),
                sensitivity_source(models, nil),
                anonymization_type,
                models
              )
            when ::Aggregate::Attribute::NestedAggregate
              nested_aggregate_columns(handler.element_helper.class_name.constantize, "#{prefix}#{key}.*.", models)
            else
              raise "Unexpected element_helper #{handler.element_helper.inspect}"
            end
          end
        end
        # rubocop:enable Metrics/BlockLength
      end
    end
  end
end
