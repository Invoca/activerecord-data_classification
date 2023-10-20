# frozen_string_literal: true

module ActiveRecord
  module DataClassification
    Column = Struct.new(
      :column,
      :type,
      :sensitivity,
      :sensitivity_source,
      :anonymization,
      :models
    ).freeze
  end
end
