# frozen_string_literal: true

# Adds the ability to specify data security to a model.
module ActiveRecord
  module DataClassification
    module ModelAnnotation
      extend ActiveSupport::Concern

      CLASSIFICATIONS = [:Public, :Private, :Confidential].freeze

      module ClassMethods
        def data_security(type = nil)
          if type
            type.in?(CLASSIFICATIONS) or raise ArgumentError, "Unknown classification type #{type}"
            self._data_security_type = type
          end
          _data_security_type
        end

        def confidential?
          _data_security_type == :Confidential
        end
      end

      included do
        class_attribute :_data_security_type
      end
    end
  end
end
