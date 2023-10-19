# frozen_string_literal: true

module ActiveRecord
  module DataClassification
    module DeclareSchema
      module Extension
        [:ruby_default, :data_security, :anonymize_using].each do |option|
          define_method(option) { @options[option] }
        end
      end
    end
  end
end
