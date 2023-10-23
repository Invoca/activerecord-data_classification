# frozen_string_literal: true

module ActiveRecord
  module DataClassification
    module ModelSpace
      class << self
        def models
          models_by_table.map do |table, all_models|
            DataClassification::ModelReflection.new(table, all_models)
          end
        end

        def all_mysql_model_tables
          models_by_table.keys
        end

        private

        def include_table?(table_name)
          DataClassification::TableSpace.all_tables.include?(table_name)
        end

        def table_for_model(model)
          model.try(:table_name)
        rescue
          # Some rails models raise an error when you call table name on them.  Ignore these.
        end

        def models_by_table
          unless @models_by_table
            @models_by_table = {}
            ObjectSpace.each_object(Class) do |model|
              table_name = table_for_model(model)
              if include_table?(table_name)
                @models_by_table[table_name] ||= []
                @models_by_table[table_name] << model
              end
            end
          end
          @models_by_table
        end
      end
    end
  end
end
