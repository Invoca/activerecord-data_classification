# frozen_string_literal: true

require 'csv'

module ActiveRecord
  module DataClassification
    module Report
      REPORT_COLUNMS = [
        "Server Type",
        "Table",
        "Column",
        "Type",
        "Sensitivity",
        "Clone Handling",
        "Models",
        "Sensitivity Source",
      ].freeze

      class << self
        def generate
          load_all_models
          assert_all_tables

          models = DataClassification::ModelSpace.models

          generate_csv(models)
        end

        private

        def generate_csv(models)
          CSV.generate(col_sep: "\t", headers: REPORT_COLUNMS) do |csv|
            csv << REPORT_COLUNMS
            found_models = Set.new
            models.sort_by(&:table_name).each do |model|
              if include_table?(model.table_name)
                fixed_name = fixed_table_name(model.table_name)
                unless found_models.member?(fixed_name)
                  found_models.add(fixed_name)
                  model.columns.map do |column|
                    csv << csv_row(model, fixed_name, column)
                  end
                end
              end
            end
          end
        end

        def csv_row(model, fixed_name, column)
          [
            model.server_type,
            fixed_name,
            column.column,
            column.type,
            column.sensitivity || ActiveRecord::DataClassification.config.default_classification,
            column.anonymization,
            column.models.map(&:name).compact.sort.join(","),
            column.sensitivity_source,
          ]
        end

        def include_table?(table_name)
          ActiveRecord::DataClassification.config.excluded_table_patterns.none? { table_name.match?(_1) }
        end

        def assert_all_tables
          missing_models = DataClassification::TableSpace.all_tables -
                           DataClassification::ModelSpace.all_mysql_model_tables -
                           ActiveRecord::DataClassification.config.ignored_tables

          if missing_models.any?
            raise "Found database tables without an associated model:  #{missing_models.inspect}"
          end
        end

        def fixed_table_name(table_name)
          ActiveRecord::DataClassification.config.table_name_transformer_block.call(table_name)
        end

        def load_all_models
          ActiveRecord::DataClassification.config.load_models_block.call
          ActiveRecord::DataClassification.config.confidential_class_names.each do |klass_name|
            make_confidential(klass_name.constantize)
          end
        end

        def make_confidential(klass)
          klass.send(:include, DataClassification::ModelAnnotation)
          klass.data_security(:Confidential)
        end
      end
    end
  end
end
