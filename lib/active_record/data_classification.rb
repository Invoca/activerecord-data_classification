# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

require_relative "data_classification/version"
require_relative "data_classification/column"
require_relative "data_classification/configuration"
require_relative "data_classification/report"
require_relative "data_classification/model_annotation"
require_relative "data_classification/model_reflection"
require_relative "data_classification/table_space"
require_relative "data_classification/model_space"

module ActiveRecord
  module DataClassification

    class << self
      def configure(&block)
        @config = Configuration.new.tap(&block).freeze
      end

      def config
        @config ||= Configuration.new
      end
    end
  end
end
